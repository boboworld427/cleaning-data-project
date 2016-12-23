Readme 
======

#### *December 22, 2016* {.date}

This is for the project of Getting and Cleaning Data. The link to the
Github Repo is:

There are 3 files :

\*readme.md

\*run\_analysis.R

\*codebook.md : This file goes through the steps in run\_analysis.R. At
the end, it shows the list of variables from the tidydata.

\*tidydata.txt: The tidy data set from codebook.md

#### A brief look at the data

The name of the data is Human Activity Recognition Using Smartphones
Dataset, which is provided in:
[http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).
The data was resulted from an experiment using a smartphone to measure
some movements when people walk,sit or lay down, etc. There were 30
subjects, which were divided into groups of test and training. There
were 6 activities these subject perform which are walking, walking
downstairs, walking upstairs, sitting, standing and laying. When the
subject were performing such activities, accelerometer and gyroscope
inside the smartphones measure the motions. For example, body
acceleration in 3 dimensions,x,y,and z, were measure or body jerking
magnitude using gyroscope were measure. For each these measurements,
quantities like mean,standard deviation,maximum or angle were estimated
and make up the columns of the original data set. Please refer to
feature.txt in the original dataset for more information.

#### Problems

The zipped file contained multiple datasets which had to be combined.
The data originally had over 500+ columns and we were not interested in
all of them. Also, the name of the columns were messy and ambiguous. The
data didn’t have any missing values.

#### Fix

\*We added and changed the variable names. We changed the abbreviated
words to full words so that the variable names become more intuitive.
Also we removed chracters like () and – because they were making the
name very messy.We used the r function grep for this.

-t -\> time  

-f -\> frequency

-Acc -\> Accelerometer

-Gyro -\> Gyroscope

-Mag -\> Magnitude

-BodyBody -\>Body

\*Also, We add eliminated all the features that are not from mean or
standard deviation measurements.

\*We added a new variable called “group” to indicate if a subject is
from the test or training group.

\*We melted the mean and standard deviation and made a new column out of
it, named “measurement”, which reduced the number of columns.

\*We reduced the number of columns 563 -\> 37.

\*We rearranged the order of columns so the identity variables come
first.

\*We rearranged the order of rows according to the subject number(1-30).
