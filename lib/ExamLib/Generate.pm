package ExamLib::Generate;

use v5.34;
use warnings;

use Exporter 'import';
use List::Util 'first', 'shuffle';

use ExamLib::Parser 'get_blocks', 'get_questions';

our @EXPORT_OK = ('generate_random_exam');

# Generate a randomized empty exam file from a parsed master exam file
sub generate_random_exam {
    my ($exam) = @_;

    my $frontmatter = %{$exam}{'exam'}->{'frontmatter'}[0]; # Get the frontmatter from the master file
    
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

1; # Magic true value