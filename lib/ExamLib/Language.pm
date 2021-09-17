package ExamLib::Language;

use v5.34;
use warnings;

use Exporter 'import';
use Lingua::StopWords 'getStopWords';
use Text::Levenshtein 'distance';
use Data::Show;

our @EXPORT_OK = ('normalize', 'compare_edit_distance');

my $lingua_stopwords = getStopWords('en');

# Remove some stopwords from the list because they would cause problems with matching
my @stopwords_blacklist = ("not", "only", "isn't", "doesn't");
delete %{$lingua_stopwords}{ @stopwords_blacklist };

my @stopwords = grep { $lingua_stopwords->{$_} } (keys %$lingua_stopwords);

my ($stopwords_regex) = map qr/(?:$_)/, join "|", map qr/\b\Q$_\E\b/, @stopwords;

# Normalize a string
sub normalize {
  my ($str) = @_;

  # Convert to lowercase
  $str = lc $str;

  # Remove stopwords
  $str =~ s/$stopwords_regex//g;

  # Trim whitespace from start and end
  $str =~ s/^\s+|\s+$//g;

  # Replace sequences of whitespace with single space
  $str =~ s/\s+/ /g;

  return $str
}

# Returns true if the levenshtein distance between two normalized strings is smaller than 10% of the normalized strings length.
sub compare_edit_distance {
  my ($str_a, $str_b) = @_;

  # Normalize both input strings
  my $str_a_normalized = normalize($str_a);
  my $str_b_normalized = normalize($str_b);

  # Calculate max edit distance
  my $max_edit_distance = int((length $str_a_normalized) / 10);

  my $edit_distance = distance($str_a_normalized, $str_b_normalized);

  return $edit_distance <= $max_edit_distance;
}

1; # Magic true value