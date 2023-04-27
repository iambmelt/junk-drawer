#!/usr/bin/perl

use strict;
use warnings;
use Text::Markdown 'markdown';

# Read the input file
my $filename = $ARGV[0];
open my $fh, '<', $filename or die "Can't open file $filename: $!";

# Read the contents of the file
my $markdown = do { local $/; <$fh> };

# Convert the markdown to HTML
my $html = markdown($markdown);

# Print the HTML
print $html;
