## Resubmission

Thank you for the feedback and instructions, I have made the following changes:

- Updated the Title field to title case 

- Changed all \notrun{} to \nottest{}

- Changed default location in llm_use() to use a temp folder

- Changed the tests to use a temp folder location

### Original submission text: 

This is a new package submission.  Run multiple 'Large Language Model' 
predictions against a table. The predictions run row-wise over a specified 
column. It works using a one-shot prompt, along with the current 
row's content. The prompt that is used will depend of the type of analysis 
needed.

The README file is very short because all the information about how to use it is
this website: https://mlverse.github.io/mall/. 

## R CMD check environments

- Mac OS M3 (aarch64-apple-darwin23), R 4.4.1 (Local)

- Mac OS x86_64-apple-darwin20.0 (64-bit), R 4.4.1 (GH Actions)
- Windows  x86_64-w64-mingw32 (64-bit), R 4.4.1 (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.4.1 (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.5.0 (dev) (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.3.3 (old release) (GH Actions)

## R CMD check results

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
