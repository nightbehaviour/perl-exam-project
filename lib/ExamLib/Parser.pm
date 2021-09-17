package ExamLib::Parser;

use v5.34;
use warnings;

use Exporter 'import';
use Regexp::Grammars; # Grammars Module

our @EXPORT_OK = ('parse_exam_file', 'get_blocks', 'get_questions');

# Uses the Regexp::Grammars module to parse a raw exam file into a operable form.
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

# Get a list of blocks from a parsed exam file
sub get_blocks {
  my ($exam) = @_;
  return @{%{$exam}{'exam'}->{'block'}};
}

# Get a list of question hashes from a parsed exam file
sub get_questions {
  my ($exam) = @_;
  my @blocks = get_blocks($exam);

  # Get the questions from all blocks which contain questions
  my @questions = map { ($_->{'question'}) ? $_->{'question'} : ()} @blocks;
}

1; # Magic true value