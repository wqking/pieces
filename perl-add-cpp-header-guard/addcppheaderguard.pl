use strict;
use warnings;
use File::Basename;

# The folders or files to scan files.
# For folder, @filePatterns will be used to search file.
my @sourceFolders = (
	'.'
);

# regular expression, not wildcard
my @filePatterns = ( qr/\.h$/i, qr/\.hpp$/i );

# regular expressions
my @ignores = ();

sub makeGuard
{
	my ($fileName, $ext) = @_;
	$fileName =~ s/\./_/g;
	
	my @set = ( '0'..'3', '5'..'9' );
	my $postfix = join '' => map $set[rand scalar(@set)], 1 .. 12;
	return uc($fileName) . '_' . uc($ext) . '_' . $postfix;
}

sub isGuard
{
	my ($line, $fileName, $ext) = @_;

	return $line =~ /#(ifndef|define)\s+[\w\d_]+_\d{10,}/;
}

&doMain;

sub doMain
{
	srand();
	foreach my $folder (@sourceFolders) {
		processFolder($folder);
	}
}

sub processFolder
{
	my ($folderName) = @_;
	
	my @fileList = glob($folderName . '/*');
	foreach my $file (@fileList) {
		if(-d $file) {
			&processFolder($file);
		}
		else {
			foreach my $filePattern (@filePatterns) {
				if($file =~ $filePattern) {
					&processFile($file);
					last;
				}
			}
		}
	}
}

sub processFile
{
	my ($fileName) = @_;
	
	foreach my $ignore (@ignores) {
		if($fileName =~ $ignore) {
			return;
		}
	}

	open FH, '<' . $fileName or die "Can't read $fileName.\n";
	my @sourceLines = <FH>;
	close FH;

	my ($name, $path, $ext) = fileparse($fileName, qr/\.[^.]*/);
	$ext =~ s/\.//;

	foreach my $line (@sourceLines) {
		if(isGuard($line, $name, $ext)) {
			return;
		}
	}

	my $guard = makeGuard($name, $ext);
	
	my $beforeMainCode = 1;
	
	my $outText = '';

	$outText .= '#ifndef ' . $guard . "\n";
	$outText .= '#define ' . $guard . "\n";
	$outText .= "\n";

	foreach my $line (@sourceLines) {
		$outText .=  $line;
	}
	$outText .= "\n";
	$outText .= "#endif\n";

	if($outText ne join('', @sourceLines)) {
		open FH, '>' . $fileName or die "Can't write $fileName.\n";
		print FH $outText;
		close FH;
	}
}

