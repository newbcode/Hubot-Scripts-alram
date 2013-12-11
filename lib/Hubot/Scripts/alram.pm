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

    $robot->enter(

            sub {
                    my $msg = shift;
                    my $user = $msg->message->user->{name};

                    if ( $user =~ /^misskang/) {
                
                        my $gm_msg = "ascii GM\n 2013년 펄 크리스마스 달력 사랑해 주세요!.";
                        my $ga_msg = '점심시간이네요 다들 맛점 하세요♥ ';
                        my $gn_msg = '수고 많으셨습니다. 다들 컴백홈!';
                        my $std_msg = '[0∼30:좋음][31∼80보통][81∼120/민감군 영향][121∼200:나쁨][201∼300:매우나쁨][301∼600:위험]';

                        $cron->add( '*/5 * * * *'  => sub {
                            my $dt = DateTime->now( time_zone => 'Asia/Seoul' );
                            my ($ymd, $year, $month, $day, $hour, $min ) = ($dt->ymd, $dt->year, $dt->month, $dt->day, $dt->hour, $dt->min);

                            if ( $month < 10 ) { $month = "0"."$month"; }
                            if ( $day < 10 ) { $day = "0"."$day"; }
                            if ( $hour < 10 ) { $hour = "0"."$hour"; }
                            if ( $min < 10 ) { $min = "0"."$min"; }

                            my $now_time = "$ymd".'-'."$hour".':'."$min";

                            if ( $now_time =~ /^\d\d\d\d\-\d\d\-\d\d\-09:30$/ ) { 
                                $msg->send($gm_msg); 
                                pods($msg);
                            }
                            elsif ( $now_time =~ /^\d\d\d\d\-\d\d\-\d\d\-11:50$/ ) { 
                                $msg->send($ga_msg); 
                                pods($msg);
                            }
                            elsif ( $now_time =~ /^\d\d\d\d\-\d\d\-\d\d\-18:35$/ ) { 
                                $msg->send($gn_msg); 
                                pods($msg);
                            }
                        }
                    );
                }
                $cron->start;
            }
    );
}

sub pods {
    my $msg = shift;
    my ($today, $pol, $cai, $cdata);

    $msg->http("http://openapi.seoul.go.kr:8088/$ENV{HUBOT_OPENAPI_KEY}/xml/ForecastWarningMinuteParticleOfDustService/1/1/")->get(
            sub {
                my ( $body, $hdr ) = @_;
                return if ( !$body || $hdr->{Status} !~ /^2/ );
                my $decode_body = decode ( 'UTF-8', $body ); 

                if ( $decode_body =~ /<APPLC_DT>(\d+)<\/APPLC_DT>/ ) {
                    $today = $1;
                }
                if ( $decode_body =~ /<POLLUTANT>(.*?)<\/POLLUTANT>/ ) {
                    $pol = $1;
                }
                if ( $decode_body =~ /<CAISTEP>(.*?)<\/CAISTEP>/ ) {
                    $cai = $1;
                }
                if ( $decode_body =~ /<ALARM_CNDT><!\[CDATA\[(.+)/ ) {
                    $cdata = $1;
                }
            $msg->send("[미세먼지 예보=> 오염물질-$pol\[$cai\] 미세먼지 농도-$cdata]"); 
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
