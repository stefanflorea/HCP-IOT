use strict;
use warnings;
use 5.010;
use LWP;
use JSON;

package HCP::IOT::DataType;

use base 'Exporter';
our @EXPORT_OK = ('get');

use Moose;
extends 'HCP::IOT::Base';

sub get {
    my $self = shift;

    my $res = $self->send_request(
        "GET",
        $self->iot_service_url . "/com.sap.iotservices.dms/api/datatypes", undef, undef
    );

    if( $res->is_success ) {
        return JSON::decode_json $res->content;
    }
    else {
        say $res->status_line, "\n";
    }
    return {};
}

no Moose;
__PACKAGE__->meta->make_immutable;
