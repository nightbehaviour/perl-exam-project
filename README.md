# Automated exam assessment
## Introduction to Perl for Programmers - Final Project
### Solution by Dario Breitenstein & Hanna Lisa Franz

------------------
## General

### Assignment Parts

We addressed the following parts of the assignment in our solution:
- Part 1 (Parsing & generating master exam files, Scoring student exam files)
- Part 2 (Inexact matching of questions and answers)

------------------
## Requirements & Usage

### Requirements

The following external Perl packages were used in the solution:
- `File::Slurper` - for reading files
- `Regexp::Grammars` - for parsing master files using regex grammars
- `Lingua::StopWords` - a list of stop words
- `Text::Levenshtein` - for calculating the edit distance between two strings

### Usage

For convenience, this repository includes sample master files and solutions in the `data` directory.

```
./generate_exam.pl <master_files>

Generates a randomized, empty exam file for one or multiple exam master files.
Output files are stored in the format "YYYYMMDD-HHMMSS-<original filename>" in the working directory.
```

```
./score_exam.pl <master_file> <student_files>

Parses and scores all given student files against a given exam master file.
```

------------------
## Implementation Details

### Modules

Generic tasks related to this projects were divided into several reusable modules:
- `ExamLib::Parser` - Parses raw exam files into an operable structure
- `ExamLib::Generate` - Generates empty randomized exam files from parsed master files
- `ExamLib::Language` - Provides subroutines to normalize strings and compare them using the Levenshtein edit distance
- `ExamLib::Util` - Provides various utility subroutines used throughout the project.

### Parsing exam files

Exam files are parsed using the `Regexp::Grammars` module. The grammar divides the anatomy of an exam master file into multiple elements:
- **Frontmatter** is the Description and any text that is placed before the first divider line (underscore characters)
- **Blocks** are separated by vertical whitespace and can contain one of two types of data:
  - **Dividers** are lines which separate questions.
  - **Questions** combine the individual elements of each numbered question:
    - *Question Number*
    - *Question Text*
    - *Options*

The `Grammars` module allows us to parse the raw files robustly into a generic data structure being tolerant of whitespace differences etc.

### Inexact "Fuzzy" matching for questions and answers

Normalisation and *fuzzy* comparison of strings was implemented in two steps:

*Normalization*
- Strings are converted into lowercase
- Whitespace is trimmed from the beginning and the end of the string
- Stop words are removed
- Series of whitespace characters within the string are replaced with a single space

*Fuzzy matching*
- The maximum edit distance is determined by the length of the normalized original string divided by 10.
- The edit distance between the two given normalized strings is determined using the `Text::Levenshtein` module.
- If the edit distance is less than or equal to the maximum edit distance, we consider the strings to match.