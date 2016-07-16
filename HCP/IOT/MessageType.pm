use strict;
use warnings;
use 5.010;
use LWP;
use JSON;

package HCP::IOT::MessageType;

use base 'Exporter';
our @EXPORT_OK = ('register','get','delete');

use Moose;
extends 'HCP::IOT::Base';

sub register {
    my $self = shift;
    my( $params ) = @_;

    my $res = $self->send_request(
        "POST",
        $self->iot_service_url . "/com.sap.iotservices.dms/api/messagetypes",
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
    my $message_type_id = shift;

    $self->iot_service_url( $self->iot_service_url . "/com.sap.iotservices.dms/api/messagetypes" );

    if( defined $message_type_id ) {
        $self->iot_service_url( $self->iot_service_url . "/$message_type_id" ); 
    }

    my $res = $self->send_request("GET", $self->iot_service_url, undef, undef);

    return {
        success => $res->is_success,
        status_line => defined $res->status_line ? $res->status_line : undef,
        content => JSON::decode_json $res->content
    };
}

sub get_for_device_type {
    my $self = shift;
    my( $device_type_id, $direction ) = @_;

    if( !defined $device_type_id || !defined $direction ) {
        return undef;
    }

    my $message_type_list_res = $self->get;
    if( $message_type_list_res->{success} ) {
        my @message_type_list = @{$message_type_list_res->{content}};
        foreach my $message_type( @message_type_list ) {
            if( $message_type->{device_type} eq $device_type_id && $message_type->{direction} eq $direction ) {
                return $message_type;
            }
        }
    }

    return undef;
}

sub delete {
    my $self = shift;
    my $message_type_id = shift;
    
    if( !defined $message_type_id ) {
        return 0;
    }

    my $res = $self->send_request("DELETE", $self->iot_service_url . "/com.sap.iotservices.dms/api/messagetypes/$message_type_id", undef, undef);
    return $res->is_success;
}

no Moose;
__PACKAGE__->meta->make_immutable;
