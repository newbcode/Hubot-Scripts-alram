package Hubot::Scripts::alram;

use utf8;
use strict;
use warnings;
use Encode qw(encode decode);
use Data::Printer;
use DateTime;
use AnyEvent::DateTime::Cron;
use LWP::UserAgent;

sub load {
    my ( $class, $robot ) = @_;

    my $cron = AnyEvent::DateTime::Cron->new(time_zone => 'Asia/Seoul');

    $robot->enter(

            sub {
                    my $msg = shift;
                    my $user = $msg->message->user->{name};

                    if ( $user =~ /^misskang/) {

                                       
                        my $gm_msg = "ascii GM";
                        my $ga_msg = '즐거운 점심시간 맛점♥';
                        my $gn_msg = '퇴근 30분전..... 조심히 컴백홈 하세요';
                       
                        $cron->add( '*/1 * * * *'  => sub {
                            my $dt = DateTime->now( time_zone => 'Asia/Seoul' );
                            my ($ymd, $year, $month, $day, $hour, $min ) = ($dt->ymd, $dt->year, $dt->month, $dt->day, $dt->hour, $dt->min);

                            if ( $month < 10 ) { $month = "0"."$month"; }
                            if ( $day < 10 ) { $day = "0"."$day"; }
                            if ( $hour < 10 ) { $hour = "0"."$hour"; }
                            if ( $min < 10 ) { $min = "0"."$min"; }

                            my $now_time = "$ymd".'-'."$hour".':'."$min";
                            my $yymmdd = "$year$month$day";

                            my $ta_msg = weather($yymmdd);

                            my ($pods_status, $pods_msg) = pods();

                            if ( $now_time =~ /^\d\d\d\d\-\d\d\-\d\d\-09:30$/ ) { 
                                $msg->send($gm_msg); 
                            }
                            elsif ( $now_time =~ /^\d\d\d\d\-\d\d\-\d\d\-10:30$/ ) { 
                                $msg->send("오늘날씨(서울)[$ta_msg] 미세먼지농도-[$pods_msg($pods_status)]");
                            }
                            elsif ( $now_time =~ /^\d\d\d\d\-\d\d\-\d\d\-11:50$/ ) { 
                                $msg->send($ga_msg); 
                            }
                            elsif ( $now_time =~ /^\d\d\d\d\-\d\d\-\d\d\-16:30$/ ) { 
                                $msg->send("오늘날씨(서울)[$ta_msg] 미세먼지농도-[$pods_msg($pods_status)]");
                            }
                            elsif ( $now_time =~ /^\d\d\d\d\-\d\d\-\d\d\-17:45$/ ) { 
                                $msg->send($gn_msg); 
                            }
                        }
                    );
                }
                $cron->start;
            }
    );
}

sub pods {
    my $ua = LWP::UserAgent->new;
    my $cdata;

    my $url = "http://openapi.seoul.go.kr:8088/$ENV{HUBOT_OPENAPI_KEY}/xml/ForecastWarningMinuteParticleOfDustService/1/1/";
    my $resp = $ua->get($url);

    my %status = (
        '0~30'         => '좋음',
        '31~80'        => '보통',
        '81~120'       => '민감군 영향',
        '121~200'      => '나쁨',
        '201~300'      => '매우나쁨',
        '301~600'      => '위험',
    );

        if ($resp->is_success) {
            my $decode_body = $resp->decoded_content;

            if ( $decode_body =~ /<ALARM_CNDT><!\[CDATA\[.*?(\d+~\d+)/ ) {
                $cdata = $1;
                foreach my $num ( keys %status ) {
                    if ($num eq $cdata) {
                        return ($num, $status{$num}); 
                    }
                }
            }
        }
        else {
            die $resp->status_line;
        }
}

sub weather {
    my $today = shift;
    my ($ta_min, $ta_max);

    my $ua = LWP::UserAgent->new;
    my $url = "http://openapi.seoul.go.kr:8088/$ENV{HUBOT_OPENAPI_KEY}/xml/DailyWeatherStation/1/5/$today";
    my $resp = $ua->get($url);

    if ($resp->is_success) {

        my $decode_body =  $resp->decoded_content;

        if ( $decode_body =~ /<SAWS_TA_MIN>(.+)<\/SAWS_TA_MIN>/ ) {
            $ta_min = $1;
        }
        if ( $decode_body =~ /<SAWS_TA_MAX>(.+)<\/SAWS_TA_MAX>/ ) {
            $ta_max = $1;
        }
    return ("$ta_min/$ta_max");

    }
    else {
        die $resp->status_line;
    }
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
