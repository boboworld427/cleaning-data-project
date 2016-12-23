Codebook 
========

#### *December 22, 2016* 

### Download the file

The files were manually downloaded and unzipped in the working
directory. The zipped file had seperate datasets and they had to be
combined.

``` {.r}
feature<-read.table("features.txt",header = F)
activity_labels<-read.table("activity_labels.txt")

X_test<-read.table("X_test.txt",header=F)
Y_test<-read.table("y_test.txt",header=F)
subject_test<-read.table("subject_test.txt")

X_train<-read.table("X_train.txt",header=F)
Y_train<-read.table("y_train.txt",header=F)
subject_train<-read.table("subject_train.txt")
```

### Before combining the dataset

The columns in the data sets were not named initally, so we named them
accordingly. Also, the activity columns were numeric, so we changed them
to factors and labelled them.

``` {.r}
names(subject_test)<-"ID"
names(subject_train)<-"ID"

names(Y_test)<-"activity"
names(Y_train)<-"activity"
Y_test$activity<-factor(Y_test$activity,labels=activity_labels$V2)  #change the numeric values to 
Y_train$activity<-factor(Y_train$activity,labels=activity_labels$V2)#factors and label the factors.


feature.names<-as.character(feature$V2)
names(X_test)<-feature.names 
names(X_train)<-feature.names
```

### Extracting the mean and standard deviation columns

Of 561 features, we were only interested in the mean and the standard
deviation measurements. We extracted the columns using grep function and
tidied the variable names a little bit but not completely yet.

``` {.r}
MeanAndStd<-grep("[Mm][Ee][Aa][Nn]|[Ss][Tt][Dd]",names(X_test))
X_test<-X_test[,MeanAndStd]                
X_train<-X_train[,MeanAndStd]
meanFreqAngle<-grep("[Mm][Ee][Aa][Nn][Ff][Rr][Ee][Qq]|[Aa][Nn][Gg][Ll][Ee]",names(X_test))
X_test<-X_test[,-meanFreqAngle]
X_train<-X_train[,-meanFreqAngle]
names(X_test)<-gsub("\\()|-","",names(X_test))
names(X_train)<-gsub("\\()|-","",names(X_train))
```

### Combining

Firstly, the ID,activity and feature were combined into two data sets:
test and train.

Before combining the test and the train sets, we added a new factor
variable named group which has two levels,c(“test”,“train”), and
assigned “test” to the subjects in the test data and “train” to the
subjects in the train data, so we don’t lose this information after
combining the two data sets.

``` {.r}
X_test<-cbind(subject_test,Y_test,X_test)    #combine with ID and activity columns
X_train<-cbind(subject_train,Y_train,X_train)

X_test<-cbind(group=factor("test"),X_test)   
X_train<-cbind(group=factor("training"),X_train)
```

We load dplyr package.

``` {.r}
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` {.r}
X_test<-tbl_df(X_test)
X_train<-tbl_df(X_train)

fulltable<-rbind(X_test,X_train)
```

### Further tidying

Now we had the combined “fulltable”. However, we still had too many
columns and we wanted the table to look slimmer. It seems like for each
feature, there were two measurements: mean and standard deviation, and
this was doubling the number of columns. So we divide the tables into
mean measurement and standard deviation measurement, and added a new
factor variable called measure, which had has levels,c(“mean”,“standard
deviation”), and assigned them accordingly. Then, we recombined the
table. This procedure halved the number of columns but it also doubled
the number of rows.

``` {.r}
fulltable<-fulltable %>% select(ID,activity,group,grep("[Mm][Ee][Aa][Nn]",names(fulltable)),grep("[Ss][Tt][Dd]",names(fulltable)))%>%arrange(ID,activity,group)
#Selecting only he measure from mean and std


meantable<-fulltable %>% select(ID:group,grep("[Mm][Ee][Aa][Nn]",names(fulltable))) %>% mutate(measure=factor("mean")) 
stdtable<-fulltable %>%select(ID:group,grep("[Ss][Tt][Dd]",names(fulltable))) %>% mutate(measure=factor("standardDeviation"))

meantable<-select(meantable,ID:group,measure,grep("[Mm][Ee][Aa][Nn]",names(meantable))) 
stdtable<-select(stdtable,ID:group,measure,grep("[Ss][Tt][Dd]",names(stdtable)))

names(meantable)<-gsub("mean","",names(meantable))
names(stdtable)<-gsub("std","",names(stdtable))

newtable<-rbind(meantable,stdtable)
newtable<-select(newtable,ID,group,activity,measure,5:37)
```

### tidying the column names

We are almost done. Finally, we modified the names of the columns so
they are more descriptive.

``` {.r}
names(newtable)<-gsub("^t","time",names(newtable))
names(newtable)<-gsub("^f","freqency",names(newtable))
names(newtable)<-gsub("[Bb][Oo][Dd][Yy][Bb][Oo][Dd][Yy]","Body",names(newtable))
names(newtable)<-gsub("[Aa][Cc][Cc]","Accelerometer",names(newtable))
names(newtable)<-gsub("[Gg][Yy][Rr][Oo]","Gyroscope",names(newtable))
names(newtable)<-gsub("[Mm][Aa][Gg]","Magnitute",names(newtable))
```

We wanted to make it shorter and not use the uppercase but couldn’t
found a way around it.

### Brief look before we go to step5

The resulting table looked like this

``` {.r}
dim(newtable)
```

    ## [1] 20598    37

``` {.r}
str(newtable)
```

    ## Classes 'tbl_df', 'tbl' and 'data.frame':    20598 obs. of  37 variables:
    ##  $ ID                                    : int  1 1 1 1 1 1 1 1 1 1 ...
    ##  $ group                                 : Factor w/ 2 levels "test","training": 2 2 2 2 2 2 2 2 2 2 ...
    ##  $ activity                              : Factor w/ 6 levels "WALKING","WALKING_UPSTAIRS",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ measure                               : Factor w/ 2 levels "mean","standardDeviation": 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ timeBodyAccelerometerX                : num  0.282 0.256 0.255 0.343 0.276 ...
    ##  $ timeBodyAccelerometerY                : num  -0.0377 -0.06455 0.00381 -0.01445 -0.02964 ...
    ##  $ timeBodyAccelerometerZ                : num  -0.1349 -0.0952 -0.1237 -0.1674 -0.1426 ...
    ##  $ timeGravityAccelerometerX             : num  0.945 0.941 0.946 0.952 0.947 ...
    ##  $ timeGravityAccelerometerY             : num  -0.246 -0.252 -0.264 -0.26 -0.257 ...
    ##  $ timeGravityAccelerometerZ             : num  -0.0322 -0.0329 -0.0256 -0.0261 -0.0284 ...
    ##  $ timeBodyAccelerometerJerkX            : num  -0.156 -0.208 0.202 0.336 -0.236 ...
    ##  $ timeBodyAccelerometerJerkY            : num  -0.143 0.358 0.417 -0.464 -0.112 ...
    ##  $ timeBodyAccelerometerJerkZ            : num  -0.11308 -0.4524 0.13908 -0.00503 0.17265 ...
    ##  $ timeBodyGyroscopeX                    : num  -0.47973 0.09409 0.2112 0.09608 0.00874 ...
    ##  $ timeBodyGyroscopeY                    : num  0.082 -0.3092 -0.2729 -0.1634 0.0117 ...
    ##  $ timeBodyGyroscopeZ                    : num  0.25644 0.08644 0.10199 0.02586 0.00417 ...
    ##  $ timeBodyGyroscopeJerkX                : num  0.0942 0.1667 -0.1632 -0.0546 -0.0757 ...
    ##  $ timeBodyGyroscopeJerkY                : num  -0.47621 -0.0338 -0.00556 0.34029 0.17147 ...
    ##  $ timeBodyGyroscopeJerkZ                : num  -0.1421 -0.0893 -0.2316 -0.2697 0.1365 ...
    ##  $ timeBodyAccelerometerMagnitute        : num  -0.2246 -0.1265 -0.1601 -0.0735 -0.0495 ...
    ##  $ timeGravityAccelerometerMagnitute     : num  -0.2246 -0.1265 -0.1601 -0.0735 -0.0495 ...
    ##  $ timeBodyAccelerometerJerkMagnitute    : num  -0.289 -0.139 -0.194 -0.129 -0.16 ...
    ##  $ timeBodyGyroscopeMagnitute            : num  -0.0344 -0.1409 -0.0946 -0.0493 -0.0214 ...
    ##  $ timeBodyGyroscopeJerkMagnitute        : num  -0.466 -0.39 -0.374 -0.236 -0.22 ...
    ##  $ freqencyBodyAccelerometerX            : num  -0.261 -0.151 -0.23 -0.151 -0.226 ...
    ##  $ freqencyBodyAccelerometerY            : num  -0.1226 -0.029 0.0254 0.1953 0.1103 ...
    ##  $ freqencyBodyAccelerometerZ            : num  -0.331 -0.257 -0.377 -0.321 -0.205 ...
    ##  $ freqencyBodyAccelerometerJerkX        : num  -0.21 -0.178 -0.193 -0.183 -0.285 ...
    ##  $ freqencyBodyAccelerometerJerkY        : num  -0.2635 -0.1208 -0.1096 -0.026 -0.0111 ...
    ##  $ freqencyBodyAccelerometerJerkZ        : num  -0.536 -0.499 -0.526 -0.487 -0.426 ...
    ##  $ freqencyBodyGyroscopeX                : num  -0.185 -0.205 -0.317 -0.162 -0.237 ...
    ##  $ freqencyBodyGyroscopeY                : num  -0.198 -0.2458 -0.2082 0.0266 0.0472 ...
    ##  $ freqencyBodyGyroscopeZ                : num  -0.308 -0.311 -0.186 -0.18 -0.258 ...
    ##  $ freqencyBodyAccelerometerMagnitute    : num  -0.1668 -0.0793 -0.1563 -0.1044 -0.1232 ...
    ##  $ freqencyBodyAccelerometerJerkMagnitute: num  -0.154 -0.178 -0.149 -0.132 -0.116 ...
    ##  $ freqencyBodyGyroscopeMagnitute        : num  -0.22218 -0.26828 -0.30867 -0.06013 -0.00382 ...
    ##  $ freqencyBodyGyroscopeJerkMagnitute    : num  -0.432 -0.428 -0.401 -0.218 -0.188 ...

### The final step

Now, We wanted to take the average of each feature for each activity and
each subject. To accomplish this, we used aggregate. However, We
splitted the data based not only on ID and activity, but also on group
and measure as well since we had the additional characteristics for each
feature.

Finally, we exported the table.

``` {.r}
newtable2<-aggregate(. ~ID+group+activity+measure, newtable, mean)
newtable2<-arrange(newtable2,ID)  
```

Let’s have a look at the small proportion of the table.

``` {.r}
head(newtable2,24)
```

    ##    ID    group           activity           measure timeBodyAccelerometerX
    ## 1   1 training            WALKING              mean             0.27733076
    ## 2   1 training   WALKING_UPSTAIRS              mean             0.25546169
    ## 3   1 training WALKING_DOWNSTAIRS              mean             0.28918832
    ## 4   1 training            SITTING              mean             0.26123757
    ## 5   1 training           STANDING              mean             0.27891763
    ## 6   1 training             LAYING              mean             0.22159824
    ## 7   1 training            WALKING standardDeviation            -0.28374026
    ## 8   1 training   WALKING_UPSTAIRS standardDeviation            -0.35470803
    ## 9   1 training WALKING_DOWNSTAIRS standardDeviation             0.03003534
    ## 10  1 training            SITTING standardDeviation            -0.97722901
    ## 11  1 training           STANDING standardDeviation            -0.99575990
    ## 12  1 training             LAYING standardDeviation            -0.92805647
    ## 13  2     test            WALKING              mean             0.27642659
    ## 14  2     test   WALKING_UPSTAIRS              mean             0.24716479
    ## 15  2     test WALKING_DOWNSTAIRS              mean             0.27761535
    ## 16  2     test            SITTING              mean             0.27708735
    ## 17  2     test           STANDING              mean             0.27791147
    ## 18  2     test             LAYING              mean             0.28137340
    ## 19  2     test            WALKING standardDeviation            -0.42364284
    ## 20  2     test   WALKING_UPSTAIRS standardDeviation            -0.30437641
    ## 21  2     test WALKING_DOWNSTAIRS standardDeviation             0.04636668
    ## 22  2     test            SITTING standardDeviation            -0.98682228
    ## 23  2     test           STANDING standardDeviation            -0.98727189
    ## 24  2     test             LAYING standardDeviation            -0.97405946
    ##    timeBodyAccelerometerY timeBodyAccelerometerZ timeGravityAccelerometerX
    ## 1            -0.017383819            -0.11114810                 0.9352232
    ## 2            -0.023953149            -0.09730200                 0.8933511
    ## 3            -0.009918505            -0.10756619                 0.9318744
    ## 4            -0.001308288            -0.10454418                 0.8315099
    ## 5            -0.016137590            -0.11060182                 0.9429520
    ## 6            -0.040513953            -0.11320355                -0.2488818
    ## 7             0.114461337            -0.26002790                -0.9766096
    ## 8            -0.002320265            -0.01947924                -0.9563670
    ## 9            -0.031935943            -0.23043421                -0.9505598
    ## 10           -0.922618642            -0.93958629                -0.9684571
    ## 11           -0.973190056            -0.97977588                -0.9937630
    ## 12           -0.836827406            -0.82606140                -0.8968300
    ## 13           -0.018594920            -0.10550036                 0.9130173
    ## 14           -0.021412113            -0.15251390                 0.7907174
    ## 15           -0.022661416            -0.11681294                 0.8618313
    ## 16           -0.015687994            -0.10921827                 0.9404773
    ## 17           -0.018420827            -0.10590854                 0.8969286
    ## 18           -0.018158740            -0.10724561                -0.5097542
    ## 19           -0.078091253            -0.42525752                -0.9726932
    ## 20            0.108027280            -0.11212102                -0.9344077
    ## 21            0.262881789            -0.10283791                -0.9403618
    ## 22           -0.950704499            -0.95982817                -0.9799888
    ## 23           -0.957304989            -0.94974185                -0.9866858
    ## 24           -0.980277399            -0.98423330                -0.9590144
    ##    timeGravityAccelerometerY timeGravityAccelerometerZ
    ## 1                 -0.2821650               -0.06810286
    ## 2                 -0.3621534               -0.07540294
    ## 3                 -0.2666103               -0.06211996
    ## 4                  0.2044116                0.33204370
    ## 5                 -0.2729838                0.01349058
    ## 6                  0.7055498                0.44581772
    ## 7                 -0.9713060               -0.94771723
    ## 8                 -0.9528492               -0.91237941
    ## 9                 -0.9370187               -0.89593970
    ## 10                -0.9355171               -0.94904093
    ## 11                -0.9812260               -0.97632406
    ## 12                -0.9077200               -0.85236629
    ## 13                -0.3466071                0.08472709
    ## 14                -0.4162149               -0.19588824
    ## 15                -0.3257801               -0.04388902
    ## 16                -0.1056300                0.19872677
    ## 17                -0.3700627                0.12974716
    ## 18                 0.7525366                0.64683488
    ## 19                -0.9721169               -0.97207285
    ## 20                -0.9237675               -0.87800406
    ## 21                -0.9400685               -0.93143831
    ## 22                -0.9567503               -0.95441587
    ## 23                -0.9741944               -0.94592708
    ## 24                -0.9882119               -0.98423042
    ##    timeBodyAccelerometerJerkX timeBodyAccelerometerJerkY
    ## 1                  0.07404163               0.0282721096
    ## 2                  0.10137273               0.0194863076
    ## 3                  0.05415532               0.0296504490
    ## 4                  0.07748252              -0.0006191028
    ## 5                  0.07537665               0.0079757309
    ## 6                  0.08108653               0.0038382040
    ## 7                 -0.11361560               0.0670025008
    ## 8                 -0.44684389              -0.3782744260
    ## 9                 -0.01228386              -0.1016013906
    ## 10                -0.98643071              -0.9813719653
    ## 11                -0.99460454              -0.9856487325
    ## 12                -0.95848211              -0.9241492736
    ## 13                 0.06180807               0.0182492679
    ## 14                 0.07445078              -0.0097098551
    ## 15                 0.11004062              -0.0032795908
    ## 16                 0.07225644               0.0116954511
    ## 17                 0.07475886               0.0103291775
    ## 18                 0.08259725               0.0122547885
    ## 19                -0.27753046              -0.0166022363
    ## 20                -0.27612189              -0.1856489542
    ## 21                 0.14724914               0.1268280146
    ## 22                -0.98805585              -0.9779839554
    ## 23                -0.98108572              -0.9710594396
    ## 24                -0.98587217              -0.9831725412
    ##    timeBodyAccelerometerJerkZ timeBodyGyroscopeX timeBodyGyroscopeY
    ## 1                -0.004168406        -0.04183096       -0.069530046
    ## 2                -0.045562545         0.05054938       -0.166170015
    ## 3                -0.010971973        -0.03507819       -0.090937129
    ## 4                -0.003367792        -0.04535006       -0.091924155
    ## 5                -0.003685250        -0.02398773       -0.059397221
    ## 6                 0.010834236        -0.01655309       -0.064486124
    ## 7                -0.502699789        -0.47353549       -0.054607769
    ## 8                -0.706593531        -0.54487110        0.004105184
    ## 9                -0.345735032        -0.45803054       -0.126349195
    ## 10               -0.987910804        -0.97721128       -0.966473895
    ## 11               -0.992251177        -0.98719195       -0.987734440
    ## 12               -0.954855111        -0.87354387       -0.951090440
    ## 13                0.007895337        -0.05302582       -0.048238232
    ## 14                0.019481439        -0.05769126       -0.032088310
    ## 15               -0.020935168        -0.11594735       -0.004823292
    ## 16                0.007605469        -0.04547066       -0.059928680
    ## 17               -0.008371588        -0.02386239       -0.082039658
    ## 18               -0.001802649        -0.01847661       -0.111800825
    ## 19               -0.586090419        -0.56155026       -0.538453668
    ## 20               -0.573746352        -0.43925306       -0.466298337
    ## 21               -0.340122023        -0.32078923       -0.415739145
    ## 22               -0.987518212        -0.98574203       -0.978919527
    ## 23               -0.982841446        -0.97299863       -0.971441996
    ## 24               -0.988442014        -0.98827523       -0.982291609
    ##    timeBodyGyroscopeZ timeBodyGyroscopeJerkX timeBodyGyroscopeJerkY
    ## 1          0.08494482            -0.08999754            -0.03984287
    ## 2          0.05835955            -0.12223277            -0.04214859
    ## 3          0.09008501            -0.07395920            -0.04399028
    ## 4          0.06293138            -0.09367938            -0.04021181
    ## 5          0.07480075            -0.09960921            -0.04406279
    ## 6          0.14868944            -0.10727095            -0.04151729
    ## 7         -0.34426663            -0.20742185            -0.30446851
    ## 8         -0.50716867            -0.61478651            -0.60169666
    ## 9         -0.12470245            -0.48702734            -0.23882483
    ## 10        -0.94142592            -0.99173159            -0.98951807
    ## 11        -0.98064563            -0.99294511            -0.99513792
    ## 12        -0.90828466            -0.91860852            -0.96790724
    ## 13         0.08283366            -0.08188334            -0.05382994
    ## 14         0.06883740            -0.08288580            -0.04240537
    ## 15         0.09717381            -0.05810385            -0.04214703
    ## 16         0.04122775            -0.09363284            -0.04156020
    ## 17         0.08783517            -0.10556216            -0.04224195
    ## 18         0.14488285            -0.10197413            -0.03585902
    ## 19        -0.48108554            -0.38954983            -0.63414044
    ## 20        -0.16399579            -0.46485436            -0.64549134
    ## 21        -0.27941839            -0.24394059            -0.46939670
    ## 22        -0.95980371            -0.98970902            -0.99088961
    ## 23        -0.96485670            -0.97932400            -0.98344726
    ## 24        -0.96030656            -0.99323585            -0.98956754
    ##    timeBodyGyroscopeJerkZ timeBodyAccelerometerMagnitute
    ## 1             -0.04613093                    -0.13697118
    ## 2             -0.04071255                    -0.12992763
    ## 3             -0.02704611                     0.02718829
    ## 4             -0.04670263                    -0.94853679
    ## 5             -0.04895055                    -0.98427821
    ## 6             -0.07405012                    -0.84192915
    ## 7             -0.40425545                    -0.21968865
    ## 8             -0.60633200                    -0.32497093
    ## 9             -0.26876148                     0.01988435
    ## 10            -0.98793581                    -0.92707842
    ## 11            -0.99210847                    -0.98194293
    ## 12            -0.95779016                    -0.79514486
    ## 13            -0.05149392                    -0.29040759
    ## 14            -0.04451575                    -0.10732268
    ## 15            -0.07102298                     0.08995112
    ## 16            -0.04358510                    -0.96789362
    ## 17            -0.05465395                    -0.96587518
    ## 18            -0.07017830                    -0.97743549
    ## 19            -0.43549268                    -0.42254417
    ## 20            -0.46759596                    -0.20597705
    ## 21            -0.21826632                     0.21558633
    ## 22            -0.98554233                    -0.95308144
    ## 23            -0.97361012                    -0.95787497
    ## 24            -0.98803582                    -0.97287391
    ##    timeGravityAccelerometerMagnitute timeBodyAccelerometerJerkMagnitute
    ## 1                        -0.13697118                       -0.141428809
    ## 2                        -0.12992763                       -0.466503446
    ## 3                         0.02718829                       -0.089447481
    ## 4                        -0.94853679                       -0.987364196
    ## 5                        -0.98427821                       -0.992367791
    ## 6                        -0.84192915                       -0.954396265
    ## 7                        -0.21968865                       -0.074471750
    ## 8                        -0.32497093                       -0.478991622
    ## 9                         0.01988435                       -0.025787720
    ## 10                       -0.92707842                       -0.984120024
    ## 11                       -0.98194293                       -0.993096209
    ## 12                       -0.79514486                       -0.928245628
    ## 13                       -0.29040759                       -0.281424154
    ## 14                       -0.10732268                       -0.321268911
    ## 15                        0.08995112                        0.005655163
    ## 16                       -0.96789362                       -0.986774713
    ## 17                       -0.96587518                       -0.980489077
    ## 18                       -0.97743549                       -0.987741696
    ## 19                       -0.42254417                       -0.164150985
    ## 20                       -0.20597705                       -0.217389395
    ## 21                        0.21558633                        0.229617185
    ## 22                       -0.95308144                       -0.984475868
    ## 23                       -0.95787497                       -0.976675280
    ## 24                       -0.97287391                       -0.985518076
    ##    timeBodyGyroscopeMagnitute timeBodyGyroscopeJerkMagnitute
    ## 1                 -0.16097955                     -0.2987037
    ## 2                 -0.12673559                     -0.5948829
    ## 3                 -0.07574125                     -0.2954638
    ## 4                 -0.93089249                     -0.9919763
    ## 5                 -0.97649379                     -0.9949668
    ## 6                 -0.87475955                     -0.9634610
    ## 7                 -0.18697836                     -0.3253249
    ## 8                 -0.14861932                     -0.6485530
    ## 9                 -0.22572437                     -0.3065106
    ## 10                -0.93453184                     -0.9883087
    ## 11                -0.97869003                     -0.9947332
    ## 12                -0.81901017                     -0.9358410
    ## 13                -0.44654909                     -0.5479120
    ## 14                -0.21971347                     -0.5728164
    ## 15                -0.16218859                     -0.4108727
    ## 16                -0.94603509                     -0.9910815
    ## 17                -0.96346634                     -0.9839519
    ## 18                -0.95001157                     -0.9917671
    ## 19                -0.55301992                     -0.5577982
    ## 20                -0.37753217                     -0.5972917
    ## 21                -0.27484411                     -0.3431879
    ## 22                -0.96131362                     -0.9895949
    ## 23                -0.95394338                     -0.9772044
    ## 24                -0.96116405                     -0.9897181
    ##    freqencyBodyAccelerometerX freqencyBodyAccelerometerY
    ## 1                 -0.20279431                0.089712726
    ## 2                 -0.40432178               -0.190976721
    ## 3                  0.03822918                0.001549908
    ## 4                 -0.97964124               -0.944084550
    ## 5                 -0.99524993               -0.977070848
    ## 6                 -0.93909905               -0.867065205
    ## 7                 -0.31913472                0.056040007
    ## 8                 -0.33742819                0.021769511
    ## 9                  0.02433084               -0.112963740
    ## 10                -0.97641231               -0.917275006
    ## 11                -0.99602835               -0.972293102
    ## 12                -0.92443743               -0.833625556
    ## 13                -0.34604816               -0.021904810
    ## 14                -0.26672093                0.009924459
    ## 15                 0.11284116                0.278345042
    ## 16                -0.98580384               -0.957343498
    ## 17                -0.98394674               -0.959871697
    ## 18                -0.97672506               -0.979800878
    ## 19                -0.45765138               -0.169219686
    ## 20                -0.32058241                0.084880279
    ## 21                 0.01610462                0.171973973
    ## 22                -0.98736209               -0.950073754
    ## 23                -0.98905647               -0.957908842
    ## 24                -0.97324648               -0.981025106
    ##    freqencyBodyAccelerometerZ freqencyBodyAccelerometerJerkX
    ## 1                 -0.33156012                    -0.17054696
    ## 2                 -0.43334970                    -0.47987525
    ## 3                 -0.22557447                    -0.02766387
    ## 4                 -0.95918489                    -0.98659702
    ## 5                 -0.98529710                    -0.99463080
    ## 6                 -0.88266688                    -0.95707388
    ## 7                 -0.27968675                    -0.13358661
    ## 8                  0.08595655                    -0.46190703
    ## 9                 -0.29792789                    -0.08632790
    ## 10                -0.93446956                    -0.98749299
    ## 11                -0.97793726                    -0.99507376
    ## 12                -0.81289156                    -0.96416071
    ## 13                -0.45380637                    -0.30461532
    ## 14                -0.28100199                    -0.25863944
    ## 15                -0.13129077                     0.13812068
    ## 16                -0.97016217                    -0.98784879
    ## 17                -0.96247120                    -0.98097324
    ## 18                -0.98438098                    -0.98581363
    ## 19                -0.45522215                    -0.31431306
    ## 20                -0.09454498                    -0.36541544
    ## 21                -0.16203289                     0.04995906
    ## 22                -0.95686286                    -0.98945911
    ## 23                -0.94643358                    -0.98300792
    ## 24                -0.98479218                    -0.98725026
    ##    freqencyBodyAccelerometerJerkY freqencyBodyAccelerometerJerkZ
    ## 1                     -0.03522552                     -0.4689992
    ## 2                     -0.41344459                     -0.6854744
    ## 3                     -0.12866716                     -0.2883347
    ## 4                     -0.98157947                     -0.9860531
    ## 5                     -0.98541870                     -0.9907522
    ## 6                     -0.92246261                     -0.9480609
    ## 7                      0.10673986                     -0.5347134
    ## 8                     -0.38177707                     -0.7260402
    ## 9                     -0.13458001                     -0.4017215
    ## 10                    -0.98251391                     -0.9883392
    ## 11                    -0.98701823                     -0.9923498
    ## 12                    -0.93221787                     -0.9605870
    ## 13                    -0.07876408                     -0.5549567
    ## 14                    -0.18784213                     -0.5227281
    ## 15                     0.09620916                     -0.2714987
    ## 16                    -0.97713970                     -0.9851291
    ## 17                    -0.97085134                     -0.9797752
    ## 18                    -0.98276825                     -0.9861971
    ## 19                    -0.01533295                     -0.6158982
    ## 20                    -0.24355415                     -0.6250910
    ## 21                     0.08083335                     -0.4082274
    ## 22                    -0.98080423                     -0.9885708
    ## 23                    -0.97352024                     -0.9845999
    ## 24                    -0.98498739                     -0.9893454
    ##    freqencyBodyGyroscopeX freqencyBodyGyroscopeY freqencyBodyGyroscopeZ
    ## 1              -0.3390322            -0.10305942            -0.25594094
    ## 2              -0.4926117            -0.31947461            -0.45359721
    ## 3              -0.3524496            -0.05570225            -0.03186943
    ## 4              -0.9761615            -0.97583859            -0.95131554
    ## 5              -0.9863868            -0.98898446            -0.98077312
    ## 6              -0.8502492            -0.95219149            -0.90930272
    ## 7              -0.5166919            -0.03350816            -0.43656223
    ## 8              -0.5658925             0.15153891            -0.57170784
    ## 9              -0.4954225            -0.18141473            -0.23844357
    ## 10             -0.9779042            -0.96234504            -0.94391784
    ## 11             -0.9874971            -0.98710773            -0.98234533
    ## 12             -0.8822965            -0.95123205            -0.91658251
    ## 13             -0.4297135            -0.55477211            -0.39665991
    ## 14             -0.3316436            -0.48808612            -0.24860112
    ## 15             -0.1457760            -0.36191382            -0.08749447
    ## 16             -0.9826214            -0.98210092            -0.95981482
    ## 17             -0.9670371            -0.97257615            -0.96062770
    ## 18             -0.9864311            -0.98332164            -0.96267189
    ## 19             -0.6040530            -0.53304695            -0.55985664
    ## 20             -0.4763588            -0.45975849            -0.21807247
    ## 21             -0.3794367            -0.45873275            -0.42298767
    ## 22             -0.9868085            -0.97735619            -0.96352266
    ## 23             -0.9749881            -0.97103605            -0.96975430
    ## 24             -0.9888607            -0.98191062            -0.96317422
    ##    freqencyBodyAccelerometerMagnitute
    ## 1                         -0.12862345
    ## 2                         -0.35239594
    ## 3                          0.09658453
    ## 4                         -0.94778292
    ## 5                         -0.98535636
    ## 6                         -0.86176765
    ## 7                         -0.39803259
    ## 8                         -0.41626010
    ## 9                         -0.18653030
    ## 10                        -0.92844480
    ## 11                        -0.98231380
    ## 12                        -0.79830094
    ## 13                        -0.32428943
    ## 14                        -0.14531854
    ## 15                         0.29342483
    ## 16                        -0.96127375
    ## 17                        -0.96405217
    ## 18                        -0.97511020
    ## 19                        -0.57710521
    ## 20                        -0.36672824
    ## 21                        -0.02147879
    ## 22                        -0.95557560
    ## 23                        -0.96051938
    ## 24                        -0.97512139
    ##    freqencyBodyAccelerometerJerkMagnitute freqencyBodyGyroscopeMagnitute
    ## 1                             -0.05711940                     -0.1992526
    ## 2                             -0.44265216                     -0.3259615
    ## 3                              0.02621849                     -0.1857203
    ## 4                             -0.98526213                     -0.9584356
    ## 5                             -0.99254248                     -0.9846176
    ## 6                             -0.93330036                     -0.8621902
    ## 7                             -0.10349240                     -0.3210180
    ## 8                             -0.53305985                     -0.1829855
    ## 9                             -0.10405226                     -0.3983504
    ## 10                            -0.98160618                     -0.9321984
    ## 11                            -0.99253600                     -0.9784661
    ## 12                            -0.92180398                     -0.8243194
    ## 13                            -0.16906435                     -0.5307048
    ## 14                            -0.18951114                     -0.4506122
    ## 15                             0.22224741                     -0.3208385
    ## 16                            -0.98387470                     -0.9718406
    ## 17                            -0.97706530                     -0.9617759
    ## 18                            -0.98537411                     -0.9721130
    ## 19                            -0.16409197                     -0.6517928
    ## 20                            -0.26042384                     -0.4386204
    ## 21                             0.22748073                     -0.3725768
    ## 22                            -0.98412419                     -0.9613857
    ## 23                            -0.97516046                     -0.9567887
    ## 24                            -0.98456849                     -0.9610984
    ##    freqencyBodyGyroscopeJerkMagnitute
    ## 1                          -0.3193086
    ## 2                          -0.6346651
    ## 3                          -0.2819634
    ## 4                          -0.9897975
    ## 5                          -0.9948154
    ## 6                          -0.9423669
    ## 7                          -0.3816019
    ## 8                          -0.6939305
    ## 9                          -0.3919199
    ## 10                         -0.9870496
    ## 11                         -0.9946711
    ## 12                         -0.9326607
    ## 13                         -0.5832493
    ## 14                         -0.6007985
    ## 15                         -0.3801753
    ## 16                         -0.9898620
    ## 17                         -0.9778498
    ## 18                         -0.9902487
    ## 19                         -0.5581046
    ## 20                         -0.6218202
    ## 21                         -0.3436990
    ## 22                         -0.9896329
    ## 23                         -0.9777543
    ## 24                         -0.9894927

For each activity for each subject, we have the measure of average of
mean and standard deviation.

``` {.r}
write.table(newtable2, "c:/tidydata.txt", sep="\t",row.name=F)
```

### Appendix

##### The list of variables from the newtable2

    ##  [1] "ID"                                    
    ##  [2] "group"                                 
    ##  [3] "activity"                              
    ##  [4] "measure"                               
    ##  [5] "timeBodyAccelerometerX"                
    ##  [6] "timeBodyAccelerometerY"                
    ##  [7] "timeBodyAccelerometerZ"                
    ##  [8] "timeGravityAccelerometerX"             
    ##  [9] "timeGravityAccelerometerY"             
    ## [10] "timeGravityAccelerometerZ"             
    ## [11] "timeBodyAccelerometerJerkX"            
    ## [12] "timeBodyAccelerometerJerkY"            
    ## [13] "timeBodyAccelerometerJerkZ"            
    ## [14] "timeBodyGyroscopeX"                    
    ## [15] "timeBodyGyroscopeY"                    
    ## [16] "timeBodyGyroscopeZ"                    
    ## [17] "timeBodyGyroscopeJerkX"                
    ## [18] "timeBodyGyroscopeJerkY"                
    ## [19] "timeBodyGyroscopeJerkZ"                
    ## [20] "timeBodyAccelerometerMagnitute"        
    ## [21] "timeGravityAccelerometerMagnitute"     
    ## [22] "timeBodyAccelerometerJerkMagnitute"    
    ## [23] "timeBodyGyroscopeMagnitute"            
    ## [24] "timeBodyGyroscopeJerkMagnitute"        
    ## [25] "freqencyBodyAccelerometerX"            
    ## [26] "freqencyBodyAccelerometerY"            
    ## [27] "freqencyBodyAccelerometerZ"            
    ## [28] "freqencyBodyAccelerometerJerkX"        
    ## [29] "freqencyBodyAccelerometerJerkY"        
    ## [30] "freqencyBodyAccelerometerJerkZ"        
    ## [31] "freqencyBodyGyroscopeX"                
    ## [32] "freqencyBodyGyroscopeY"                
    ## [33] "freqencyBodyGyroscopeZ"                
    ## [34] "freqencyBodyAccelerometerMagnitute"    
    ## [35] "freqencyBodyAccelerometerJerkMagnitute"
    ## [36] "freqencyBodyGyroscopeMagnitute"        
    ## [37] "freqencyBodyGyroscopeJerkMagnitute"

XYZ at the end represents the 3 axis directions in X,Y and Z direction,
repectively. There are 37 variables. Each row is the average value of
each features for each activity and each subject from the original data
sets.
