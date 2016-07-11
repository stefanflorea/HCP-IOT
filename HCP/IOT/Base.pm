use strict;
use warnings;
use 5.010;
use LWP;
use JSON;

package HCP::IOT::Base;

use base 'Exporter';
our @EXPORT_OK = ('build_json_request','send_request');

use Moose;

has iot_service_url     => ( is => 'rw', isa => 'Str' );
has proxy               => ( is => 'rw', isa => 'Str' );
has token               => ( is => 'rw', isa => 'Str' );

sub build_json_request {
    my( $params ) = @_; 

    my $json_text = JSON::encode_json($params);
    return $json_text; 
}

sub send_request {
    my $self = shift;
    my( $type, $url, $content_type, $content, $authorization_type ) = @_;

    # Define the user agent
    my $ua = LWP::UserAgent->new;
    $ua->agent("HCP_IOT/0.1 ");
    $ua->proxy(['http', 'https'], $self->proxy);

    # Create a request
    my $req = HTTP::Request->new($type => $url);
    $req->content_type($content_type) if defined $content_type;
    $req->content($content) if defined $content;

    if( defined $authorization_type && $authorization_type eq "Bearer" ) {
        $req->authorization( "Bearer " . $self->token );
    } else {
        $req->authorization( "Basic " . $self->token );
    }

    # Pass request to the user agent and get a response back
    my $res = $ua->request($req);

    return $res;
}

1;

#no Moose;
#__PACKAGE__->meta->make_immutable;
