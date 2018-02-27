use strict;
use warnings;

# The folders or files to scan files.
# For folder, @filePatterns will be used to search file.
my @sourceFolders = (
);

# regular expression, not wildcard
my @filePatterns = ( qr/\.h$/i, qr/\.cpp$/i );

# regular expressions
my @ignores = (  );

my $license = <<EOM;
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//   http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
EOM

&doMain;

sub doMain
{
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
#print $fileName, "\n";
#return;

	open FH, '<' . $fileName or die "Can't read $fileName.\n";
	my @sourceLines = <FH>;
	close FH;
	
	my $beforeMainCode = 1;

	open FH, '>' . $fileName or die "Can't write $fileName.\n";
	foreach my $line (@sourceLines) {
		if($beforeMainCode) {
			if($line =~ m!^\s*//!) {
			}
			elsif($line =~ m!^\s*$!) {
			}
			else {
				print FH $license;
				print FH "\n";
				$beforeMainCode = 0;
			}
		}
		if(! $beforeMainCode) {
			print FH $line;
		}
	}
	close FH;
}
