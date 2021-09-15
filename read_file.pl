use v5.34;
use warnings;
use Data::Show;
use List::Util ('first', 'shuffle');
use Regexp::Grammars; # Grammars Module

sub parse_exam_file {
    my ($raw_content) = @_;

    my $exam_grammar = qr{
        # Start-pattern
        <exam>

        # Switch off context substring retention
        <nocontext:>

        # An Exam starts with frontmatter (description) followed by a list of blocks
        <rule: exam>
            <[frontmatter]>
            <[block]>*

        # A block is separated by whitespace and is either a question or a divider
        <rule: block>
            <question> | <divider>

        # A question must have a question text and one or more answers, followed by an empty line
        <rule: question>
            <question_text>
            <[answer]>+
            \s* \n # Matches an empty line

        # The frontmatter is any text before the first divider
        <token: frontmatter>
            [^_]*[\t\n]* # Matches all text up to a underscore

        # The question text is marked by a number followed by a block of text
        <token: question_text>
            \s* <question_number> <text>

        # Each answer has a checkbox followed by a block of text
        <token: answer>
            \s* <checkbox> <text>

        <token: checkbox>
            \[ \s*[^\]]*\s* \] # Matches any character or whitespace character enclosed by two square brackets, i.e [ ], [], [x], [X], [*] etc.

        <token: question_number>
            \s*\d+ \.

        <token: text>
            \N* \n                # Matches any line
            (?: \N* \S \N* \n )*? # Extra lines must contain a non-whitespace character

        <token: divider>
            \N* \n # Matches any line
    }xms;

    # Try matching the exam grammar
    if ($raw_content =~ $exam_grammar) {
        return \%/; # %/ Result hash for successful grammar match
    }
    else {
        die "Error: Could not parse exam file. The structure may be invalid";
    }
}

sub generate_random_exam {
    my ($exam_ref) = @_;
    my %exam = %{$exam_ref};

    my $frontmatter = $exam{'exam'}->{'frontmatter'}[0];
    
    my @blocks = @{$exam{'exam'}->{'block'}};
    my @questions = map { ($_->{'question'}) ? $_->{'question'} : ()} @blocks; # Get the questions from all blocks which contain questions
    
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
        $exam_file .= "\n" . $divider;
    }
    
    return $exam_file;
}

my @files;

if (@ARGV == 0) {
    @files = glob("data/master.txt");
}
else {
    @files = @ARGV;
}

for my $file (@files) {
    my $exam_file = read_file($file);
    my $exam = parse_exam_file($exam_file);

    print (generate_random_exam($exam));
}

sub read_file {
    my ($filepath) = @_;
    open my $fh, '<', $filepath or die colored(['red'], "Cannot read '$filepath': $!\n");
    my $bare_content = do {
        local $/;
        readline($fh)
    };
    close $fh;
    return $bare_content;
}
