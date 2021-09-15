package ExamLib::Util;

use v5.32;
use warnings;

use Exporter 'import';
use POSIX 'strftime';

our @EXPORT_OK = ('get_timestamp', 'write_text');

sub get_timestamp {
  return strftime("%Y%M%d-%H%M%S", localtime);
}

sub write_text {
  my ($filename, $text) = @_;
  open (my $fh, '>', $filename) or die "Can't write to $filename'";
  print $fh $text;
  close $fh;
}
