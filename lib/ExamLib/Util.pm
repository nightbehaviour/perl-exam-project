package ExamLib::Util;

use v5.34;
use warnings;

use Exporter 'import';
use POSIX 'strftime';

our @EXPORT_OK = ('get_timestamp', 'write_text');

# Create a YYYYMMDD-HHMMSS Timestamp String
sub get_timestamp {
  return strftime("%Y%M%d-%H%M%S", localtime);
}

# Write text from a scalar variable to a file.
sub write_text {
  my ($filename, $text) = @_;
  open (my $fh, '>', $filename) or die "Can't write to $filename'";
  print $fh $text;
  close $fh;
}

1; # Magic true value