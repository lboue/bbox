#!/usr/bin/perl

use LWP::UserAgent;
use HTML::Parser; 
use JSON;
use Data::Dumper;
use Term::ANSIColor;

sub convert_time {
  my $time = shift;
  my $days = int($time / 86400);
  $time -= ($days * 86400);
  my $hours = int($time / 3600);
  $time -= ($hours * 3600);
  my $minutes = int($time / 60);
  my $seconds = $time % 60;

  $days = $days < 1 ? '' : $days .'d ';
  $hours = $hours < 1 ? '' : $hours .'h ';
  $minutes = $minutes < 1 ? '' : $minutes . 'm ';
  $time = $days . $hours . $minutes . $seconds . 's';
  return $time;
}

my $ua = LWP::UserAgent->new;
my $server_endpoint = "http://bbox.lan/admin/index.htm";
my $server_API = "http://bbox.lan/cgi-bin/generic.cgi";
my $token;
 
# set custom HTTP request header fields
my $req = HTTP::Request->new(GET => $server_endpoint);
$req->header('content-type' => 'application/json');
 
my $response = $ua->request($req);
	if ($response->is_success) {
		my $headers = $response->headers();
		my $s_headers = $response->headers()->as_string();
		my $message = $response->decoded_content;
		my $v = $message;
		while( $v =~ m/0_[0-9a-zA-Z_]{6}/g ) {
			$token = $&;
			last;
		}
}

else {
    print "HTTP GET error code: ", $response->code, "\n";
    print "HTTP GET error message: ", $response->message, "\n";
}
#################### API CALL #################### 
# set custom HTTP request header fields
my $req = HTTP::Request->new(POST => $server_API);
$req->header('content-type' => 'application/x-www-form-urlencoded');
$req->content("token=$token&read=WLANConfig_Scheduler&read=Layer3Forwarding_ActiveConnectionService&read=WANConnectionDevice_{Layer3Forwarding_ActiveConnectionService}&read=WANDSLLinkStatus&read=VoiceProfile_1_Line_1&read=VoiceProfile_1_Line_2&read=Diag_Services_VoIP_Ringing_Status&read=Diag_Services_VoIP_Ringing_Method&read=WLANConfig_RadioEnable&read=WLANInterface_*_Config&read=LANDevice_1_Hosts&read=WLANConfig_Index_Wifi24&read=WLANConfig_Index_Wifi5G&read=Services_TR111");
 
my $response = $ua->request($req);
if ($response->is_success) {
	my $headers = $response->headers();
	my $s_headers = $response->headers()->as_string();
	my $json = $response->decoded_content;
	$decoded = decode_json($json);	
 
	#################### RESULTS #################### 
	print color 'bold';
	print "Device\n";
	print color 'reset';
	print "ProductClass = " . $decoded->{'Services_TR111'}{'Device'}{'1'}{'ProductClass'} . "\n";

	print color 'bold';
	print "\nVoice\n";
	print color 'reset';
	print "DirectoryNumber = " . $decoded->{'VoiceProfile_1_Line_1'}{'DirectoryNumber'} . "\n";
	print "Status = " . $decoded->{'Diag_Services_VoIP_Ringing_Status'}. "\n";

	print color 'bold';
	print "\nWANDSLLinkStatus\n";
	print color 'reset';
	print "DownBitrate = " . $decoded->{'WANDSLLinkStatus'}{'DownBitrates'}{'ActualRate'} . " kbps\n";
	print "UpBitrate = " . $decoded->{'WANDSLLinkStatus'}{'UpBitrates'}{'ActualRate'} . " kbps\n";
	print "Modulation = " . $decoded->{'WANDSLLinkStatus'}{'Info'}{'Modulation'} . "\n";
	print "NumberOfSync = " . $decoded->{'WANDSLLinkStatus'}{'Info'}{'NumberOfSync'} . " sync(s)\n";
	print "TimeConnected = " . convert_time($decoded->{'WANDSLLinkStatus'}{'Info'}{'TimeConnected'}) . "\n";
	print color 'bold';
	print "\nWANConnectionDevice\n";
	print color 'reset';
	print "State = " . $decoded->{'WANConnectionDevice_{Layer3Forwarding_ActiveConnectionService}'}{'1'}{'Status'}{'State'}. "\n";
	print "IPAddress = " . $decoded->{'WANConnectionDevice_{Layer3Forwarding_ActiveConnectionService}'}{'1'}{'Status'}{'IPAddress'}. "\n";
}

else {
    print "HTTP GET error code: ", $response->code, "\n";
    print "HTTP GET error message: ", $response->message, "\n";
}

