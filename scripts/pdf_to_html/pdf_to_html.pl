#!/usr/bin/perl

use strict;
use warnings;
use CAM::PDF;
use HTML::TreeBuilder;

# Read the input file
my $filename = $ARGV[0];
my $pdf = CAM::PDF->new($filename) or die "Can't open PDF file $filename: $!";

# Convert each page of the PDF to text and concatenate it
my $text = '';
for (my $page = 1; $page <= $pdf->numPages(); $page++) {
    $text .= $pdf->getPageText($page);
}

# Convert the concatenated text to HTML
my $html = "<html><head><title>$filename</title></head><body>$text</body></html>";

# Parse the HTML with HTML::TreeBuilder
my $tree = HTML::TreeBuilder->new_from_content($html);

# Output the HTML
print $tree->as_HTML;
