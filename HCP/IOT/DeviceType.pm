use strict;
use warnings;
use 5.010;
use LWP;
use JSON;

package HCP::IOT::DeviceType;

use base 'Exporter';
our @EXPORT_OK = ('register','get','delete','change_auth');

use Moose;
extends 'HCP::IOT::Base';

sub register {
    my $self = shift;
    my( $params ) = @_;

    my $res = $self->send_request(
        "POST",
        $self->iot_service_url . "/com.sap.iotservices.dms/api/devicetypes",
        "application/json;charset=utf-8",
        HCP::IOT::Base::build_json_request( $params )
    );

    return {
        success => $res->is_success,
        status_line => defined $res->status_line ? $res->status_line : undef,
        content => JSON::decode_json $res->content
    };
}

sub get {
    my $self = shift;
    my $device_type_id = shift;

    $self->iot_service_url($self->iot_service_url . "/com.sap.iotservices.dms/api/devicetypes");

    if( defined $device_type_id ) {
        $self->iot_service_url($self->iot_service_url . "/$device_type_id");
    }

    my $res = $self->send_request("GET", $self->iot_service_url, undef, undef);

    return {
        success => $res->is_success,
        status_line => defined $res->status_line ? $res->status_line : undef,
        content => JSON::decode_json $res->content
    };
}

sub delete {
    my $self = shift;
    my $device_type_id = shift;

    if( !defined $device_type_id ) {
        return 0;
    }

    $self->iot_service_url($self->iot_service_url . "/com.sap.iotservices.dms/api/devicetypes/$device_type_id");

    my $res = $self->send_request("DELETE", $self->iot_service_url, undef, undef);
    return $res->is_success;
}

sub change_auth {
    my $self = shift;
    my $device_type_id = shift;
    my $auth_type = shift;

    if( !defined $device_type_id || !defined $auth_type ) {
        return {};
    }

    $self->iot_service_url($self->iot_service_url . "/com.sap.iotservices.dms/api/devicetypes/$device_type_id/authentication");

    my $del_res = $self->send_request("DELETE", $self->iot_service_url, undef, undef);
    
    if( $del_res->is_success ) {
        my $res = $self->send_request(
            "POST",
            $self->iot_service_url,
            "application/json;charset=utf-8",
            build_json_request({ type => $auth_type })
        );
        return {
            success => $res->is_success,
            status_line => defined $res->status_line ? $res->status_line : undef,
            content => JSON::decode_json $res->content
        };
    }

    return {};
}

no Moose;
__PACKAGE__->meta->make_immutable;

