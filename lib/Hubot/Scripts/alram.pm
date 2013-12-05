package Hubot::Scripts::alram;

use 5.010;
use utf8;
use strict;
use warnings;
use Encode qw(encode decode);
use Data::Printer;
use DateTime;
use AnyEvent::DateTime::Cron;

sub load {
    my ( $class, $robot ) = @_;
    
    my $cron = AnyEvent::DateTime::Cron->new(time_zone => 'Asia/Seoul');

    $robot->hear(
            qr/^test/,

            sub {
                    my $msg = shift;
                    my $user = $msg->message->user->{name};
                    my ( $body, $hdr );
                    my $decode_body;

                    if ( $user =~ /^test/ ) {
                
                        my $gm_msg = "ascii GM\n 2013년 펄 크리스마스 달력 사랑해 주세요!.";
                        my $ga_msg = '점심시간이네요 다들 맛점 하세요♥ ';
                        my $gn_msg = 'ascii GN ';
                        my $test_msg = 'TEST MSG 입니다. ';

                        $msg->http("http://openapi.seoul.go.kr:8088/$ENV{HUBOT_OPENAPI_KEY}/xml/ForecastWarningMinuteParticleOfDustService/1/1/")->get(
                            sub {
                                    ( $body, $hdr ) = @_;
                                    return ( !$body || $hdr->{Status} !~ /^2/ );
                                    $decode_body = decode ( 'UTF-8', $body ); 
                                    if ( $decode_body =~ /<list_total_count>(\d+)<\/list_total_count>/ ) {
                                        print "$1\n";
                                    }
                                }
                            );

                        $cron->add( '*/1 * * * *'  => sub {
                            my $dt = DateTime->now( time_zone => 'Asia/Seoul' );
                            my ($ymd, $year, $month, $day, $hour, $min ) = ($dt->ymd, $dt->year, $dt->month, $dt->day, $dt->hour, $dt->min);

                            if ( $month < 10 ) { $month = "0"."$month"; }
                            if ( $day < 10 ) { $day = "0"."$day"; }
                            if ( $hour < 10 ) { $hour = "0"."$hour"; }
                            if ( $min < 10 ) { $min = "0"."$min"; }

                            my $now_time = "$ymd".'-'."$hour".':'."$min";

                            given ($now_time) {
                                when ( /^\d\d\d\d\-\d\d\-\d\d\-09:30$/ ) { $msg->send("$gm_msg"); }
                                when ( /^\d\d\d\d\-\d\d\-\d\d\-12:00$/ ) { $msg->send("$ga_msg"); }
                                when ( /^\d\d\d\d\-\d\d\-\d\d\-18:00$/ ) { $msg->send("$gn_msg"); }
                                when ( /^\d\d\d\d\-\d\d\-\d\d\-14:33$/ ) { $msg->send("$body"); }
                            }
                        }
                    );
                }
                $cron->start;
            }
    );
}

1;

=pod

=head1 Name 

    Hubot::Scripts::alram
 
=head1 SYNOPSIS

    Registered at the time the show alram. 

=head1 AUTHOR

    YunChang Kang <codenewb@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Yunchang Kang.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself
 
=cut
