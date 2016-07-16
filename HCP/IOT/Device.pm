use strict;
use warnings;
use 5.010;
use LWP;
use JSON;

package HCP::IOT::Device;

use base 'Exporter';
our @EXPORT_OK = ('register','get','get_attributes','delete','delete_attribute','update','renew_token');

use Moose;
extends 'HCP::IOT::Base';

sub register {
    my $self = shift;
    my( $params ) = @_;

    my $res = $self->send_request(
        "POST",
        $self->iot_service_url . "/com.sap.iotservices.dms/api/devices",
        "application/json;charset=utf-8",
        HCP::IOT::Base::build_json_request( $params ),
    );

    return {
        success => $res->is_success,
        status_line => defined $res->status_line ? $res->status_line : undef,
        content => JSON::decode_json $res->content
    };
}

sub get {
    my $self = shift;
    my $device_id = shift;

    $self->iot_service_url( $self->iot_service_url . "/com.sap.iotservices.dms/api/devices" );

    if( defined $device_id ) {
        $self->iot_service_url( $self->iot_service_url . "/$device_id" ); 
    }

    my $res = $self->send_request("GET", $self->iot_service_url, undef, undef);

    return {
        success => $res->is_success,
        status_line => defined $res->status_line ? $res->status_line : undef,
        content => JSON::decode_json $res->content
    };
}

sub get_attributes {
    my $self = shift;
    my $device_id = shift;

    if( !defined $device_id ) {
        return {};
    }

    $self->iot_service_url( $self->iot_service_url . "/com.sap.iotservices.dms/api/devices/$device_id/attributes" ); 

    my $res = $self->send_request("GET", $self->iot_service_url, undef, undef);

    return {
        success => $res->is_success,
        status_line => defined $res->status_line ? $res->status_line : undef,
        content => JSON::decode_json $res->content
    };
}

sub delete {
    my $self = shift;
    my $device_id = shift;
    
    if( !defined $device_id ) {
        return 0;
    }

    my $res = $self->send_request("DELETE", $self->iot_service_url . "/com.sap.iotservices.dms/api/devices/$device_id", undef, undef);
    return $res->is_success;
}

sub delete_attribute {
    my $self = shift;
    my ($device_id, $attribute_key) = @_;
    
    if( !defined $device_id || !defined $attribute_key ) {
        return 0;
    }

    my $res = $self->send_request("DELETE", $self->iot_service_url . "/com.sap.iotservices.dms/api/devices/$device_id/attributes/$attribute_key", undef, undef);
    return $res->is_success;
}

sub update {
    my $self = shift;
    my( $device_id, $params ) = @_;

    if( !defined $device_id || !defined $params ) {
        return {};
    }

    my $res = $self->send_request(
        "PATCH",
        $self->iot_service_url . "/com.sap.iotservices.dms/api/devices/$device_id/attributes",
        "application/json;charset=utf-8",
        HCP::IOT::Base::build_json_request( $params )
    );

    return {
        success => $res->is_success,
        status_line => defined $res->status_line ? $res->status_line : undef,
        content => JSON::decode_json $res->content
    };
}

sub renew_token {
    my $self = shift;
    my $device_id = shift;

    if( !defined $device_id ) {
        return {};
    }

    my $res = $self->send_request(
        "POST",
        $self->iot_service_url . "/com.sap.iotservices.dms/api/devices/$device_id/authentication/token",
        undef, undef
    );

    return {
        success => $res->is_success,
        status_line => defined $res->status_line ? $res->status_line : undef,
        content => JSON::decode_json $res->content
    };
}

no Moose;
__PACKAGE__->meta->make_immutable;
