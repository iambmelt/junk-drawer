#!/usr/bin/perl

use strict;
use warnings;
use JSON;

# Get command-line arguments
my ($config_file, $output_dir) = @ARGV;

# Read configuration file
open my $fh, '<', $config_file or die "Cannot open $config_file: $!";
my $json = join '', <$fh>;
close $fh;

# Decode JSON
my $data = decode_json($json);

# Generate Java source code for each class
for my $class (@$data) {
    # Create Java source code
    my $source_code = "package com.example;\n\n";
    $source_code .= "import $_;\n" for @{$class->{imports}};
    $source_code .= "\n";
    $source_code .= "public class $class->{name}";
    $source_code .= " extends $class->{extends}" if $class->{extends};
    $source_code .= " implements $_" for @{$class->{implements}};
    $source_code .= " {\n\n";
    $source_code .= "    " . $_->{type} . " " . $_->{name} . " = " . $_->{value} . ";\n"
        for @{$class->{constants}};
    $source_code .= "\n";
    for my $method (@{$class->{methods}}) {
        $source_code .= "    public $method->{returnType} $method->{name}(";
        $source_code .= join(", ", map { "$_->{type} $_->{name}" } @{$method->{parameters}});
        $source_code .= ") {\n";
        $source_code .= "        " . $_ . "\n" for @{$method->{body}};
        $source_code .= "    }\n\n";
    }
    $source_code .= "}\n";

    # Write Java source code to file
    my $filename = "$output_dir/$class->{name}.java";
    open my $fh, '>', $filename or die "Cannot open $filename for writing: $!";
    print $fh $source_code;
    close $fh;
}

print "Java source code files written to $output_dir\n";
