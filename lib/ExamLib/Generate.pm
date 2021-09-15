package ExamLib::Generate;

use v5.32;
use warnings;

use Exporter 'import';
use List::Util 'first', 'shuffle';

use ExamLib::Parser 'get_blocks', 'get_questions';

our @EXPORT_OK = ('generate_random_exam');

sub generate_random_exam {
    my ($exam) = @_;
    my %exam_hash = %{$exam};

    my $frontmatter = $exam_hash{'exam'}->{'frontmatter'}[0];
    
    my @blocks = get_blocks($exam);
    my @questions = get_questions($exam);
    
    my $divider = (first { $_->{'divider'} } @blocks) -> {'divider'} . "\n"; # Get first divider 
    my $empty_checkbox = '    [ ]';

    # Start the file with the extracted frontmatter
    my $exam_file = $frontmatter . $divider;

    # Print questions one after the other
    for my $question (@questions) {
        my $question_text = $question->{'question_text'};
        my @answers = @{$question->{'answer'}};

        $exam_file .= $question_text->{'question_number'} . $question_text->{'text'} . "\n"; # Print the question number and text to the file

        for my $answer (shuffle @answers) {
            $exam_file .= $empty_checkbox . $answer->{'text'}; # Print each answer to the file (with an empty checkbox)
        }

        # Insert extracted divider
        $exam_file .= "\n" . $divider . "\n";
    }
    
    return $exam_file;
}

1;
