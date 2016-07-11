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

    if( defined $params ) {
        say HCP::IOT::Base::build_json_request( $params );
        my $res = $self->send_request(
            "POST",
            $self->iot_service_url . "/com.sap.iotservices.dms/api/messagetypes",
            "application/json;charset=utf-8",
            HCP::IOT::Base::build_json_request( $params )
        );

        if( $res->is_success ) {
            say $res->content;
            return JSON::decode_json $res->content;
        }
        else {
            say $res->status_line, "\n";
        }
    }

    return {};
}

sub get {
    my $self = shift;
    my $message_type_id = shift;

    $self->iot_service_url( $self->iot_service_url . "/com.sap.iotservices.dms/api/messagetypes" );

    if( defined $message_type_id ) {
        $self->iot_service_url( $self->iot_service_url . "/$message_type_id" ); 
    }

    my $res = $self->send_request("GET", $self->iot_service_url, undef, undef);

    if( $res->is_success ) {
        return JSON::decode_json $res->content;
    } else {
        say $res->status_line, "\n";
    }

    return {};
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
