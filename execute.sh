#!/bin/sh

# Copyright (c) 2005, Wipro Technologies Ltd. All rights reserved.
# Created by:  Dr. B. Thangaraju <balat.raju@wipro.com>
#              Prashant P Yendigeri <prashant.yendigeri@wipro.com>
# This file is licensed under the GPL license.  For the full content
# of this license, see the COPYING file at the top level of this
# source tree.
#
# This execute.sh script executes executables and format the results 
# including time statistics like time taken to execute OPTS. 
# This script doesn't use 'make' or 'gcc'. This script will be useful 
# to run test cases on embedded target. 


# Run all the tests in the conformance area.

# Function to calculate starting time
start_func()
{
      START_DATE=`date`
      START_HOUR=`date +%H`
      START_MIN=`date +%M`
      START_SEC=`date +%S`

      if [ $START_HOUR -eq 0 ]
      then
            TOTAL_START_HOUR=0
            
      else
            TOTAL_START_HOUR=`expr $START_HOUR '*' 3600`
      fi

      if [ $START_MIN -eq 0 ]
      then
            TOTAL_START_MIN=0
      else
            TOTAL_START_MIN=`expr $START_MIN '*' 60`
      fi

      TOTAL_START_TEMP=`expr $TOTAL_START_HOUR + $TOTAL_START_MIN`

      TOTAL_START_SECS=`expr $TOTAL_START_TEMP + $START_SEC`
}


end_func_noday_change()
{
      END_DATE=`date`
      END_HOUR=`date +%H`
      END_MIN=`date +%M`
      END_SEC=`date +%S`

      TOTAL_END_HOUR=`expr $END_HOUR '*' 3600`
      TOTAL_END_MIN=`expr $END_MIN '*' 60`
      TOTAL_END_TEMP=`expr $TOTAL_END_HOUR + $TOTAL_END_MIN`

      TOTAL_END_SECS=`expr $TOTAL_END_TEMP + $END_SEC`
      TOTAL_TIME=`expr $TOTAL_END_SECS - $TOTAL_START_SECS`

      TOTAL_HR=`expr $TOTAL_TIME / 3600`
      TOTAL_MIN=`expr $TOTAL_TIME / 60`
      TOTAL_SEC=$TOTAL_TIME

      if [ $TOTAL_SEC -gt 60 ]
      then
            TOTAL_SEC=`expr $TOTAL_SEC % 60`
      fi

      if [ $TOTAL_MIN -gt 60 ]
      then
            TOTAL_MIN=`expr $TOTAL_MIN % 60`
      fi

      if [ $TOTAL_HR -gt 60 ]
      then
            TOTAL_HR=`expr $TOTAL_HR % 60`
      fi

}

# Function to calculate end time
end_func()
{
      END_DATE=`date`
      END_HOUR=`date +%H`
      END_MIN=`date +%M`
      END_SEC=`date +%S`


      if [ $END_HOUR -eq 0 ]
      then
            TOTAL_END_HOUR=0
      else
            TOTAL_END_HOUR=`expr $END_HOUR '*' 3600`
      fi

      if [ $END_MIN -eq 0 ]   
      then
            TOTAL_END_MIN=0
      else
            TOTAL_END_MIN=`expr $END_MIN '*' 60`
      fi


      TOTAL_END_TEMP=`expr $TOTAL_END_HOUR + $TOTAL_END_MIN`

      TOTAL_END_SECS=`expr $TOTAL_END_TEMP + $END_SEC`
      TOTAL_START_SECS=`expr 86400 - $TOTAL_START_SECS`

      TOTAL_TIME=`expr $TOTAL_END_SECS + $TOTAL_START_SECS`

      TOTAL_HR=`expr $TOTAL_TIME / 3600`

      TOTAL_MIN=`expr $TOTAL_TIME / 60`
      TOTAL_SEC=$TOTAL_TIME

      if [ $TOTAL_SEC -gt 60 ]
      then
            TOTAL_SEC=`expr $TOTAL_SEC % 60`
      fi

      if [ $TOTAL_MIN -gt 60 ]
      then
            TOTAL_MIN=`expr $TOTAL_MIN % 60`
      fi

      if [ $TOTAL_HR -gt 60 ]
      then
            TOTAL_HR=`expr $TOTAL_HR % 60`
      fi
}

# Function to display the Execution Time Statistics
display_func()
{
      echo
      echo
      echo  "*******************************************"
      echo  "*         EXECUTION TIME STATISTICS       *"
      echo  "*******************************************"
      echo  "* START    : $START_DATE *"
      echo  "* END      : $END_DATE *"
      echo  "* DURATION :                              *"
      echo  "*            $TOTAL_HR hours                      *"
      echo  "*            $TOTAL_MIN minutes                    *"
      echo  "*            $TOTAL_SEC seconds                    *"
      echo  "*******************************************"
      echo
      echo >> $PASSLOG
      echo  "*******************************************" >> $PASSLOG
      echo  "*         EXECUTION TIME STATISTICS       *" >> $PASSLOG
      echo  "*******************************************" >> $PASSLOG
      echo  "* START    : $START_DATE *" >> $PASSLOG
      echo  "* END      : $END_DATE *"
      echo  "* DURATION :                              *" >> $PASSLOG
      echo  "*            $TOTAL_HR hours                      *" >> $PASSLOG
      echo  "*            $TOTAL_MIN minutes                    *" >> $PASSLOG
      echo  "*            $TOTAL_SEC seconds                    *" >> $PASSLOG
      echo  "*******************************************" >> $PASSLOG
}

usage()
{
    cat <<EOF 
Usage: $0 [AIO|MEM|MSG|SEM|SIG|THR|TMR|TPS|ALL]

run the tests for POSIX area specified by the 3 letter tag
in the POSIX spec

EOF
}

# Variables for formatting the OPTS results


# Maximum Two minutes waiting time period to execute a test. If it exceeds, the test case will go into the 'HUNG' category.
TIMEOUT_VAL=120

# if gcc available then remove the below line comment else put the t0 in posixtestsuite directory.
#gcc -o t0 t0.c
./t0 0 > /dev/null 2>&1
TIMEVAL_RET=$?

# Find executable files from the conformance directory
# If you want to execute any specific test cases, you should modify here.
BASEDIR=./conformance/interfaces
SEARCH_DIR=$BASEDIR
STRESS_DIR=./empty
case $1 in
  AIO) echo "Executing asynchronous I/O tests"
      SEARCH_DIR="$BASEDIR/aio_* $BASEDIR/lio_listio*"
      PASSLOG=./log/aiopasslog
      FAILLOG=./log/aiofaillog
	;;
  SIG) echo "Executing signals tests"
      SEARCH_DIR="$BASEDIR/sig* $BASEDIR/raise $BASEDIR/kill $BASEDIR/killpg $BASEDIR/pthread_kill $BASEDIR/pthread_sigmask"
      PASSLOG=./log/sigpasslog
      FAILLOG=./log/sigfaillog      
	;;
  SEM) echo "Executing semaphores tests"
      SEARCH_DIR="$BASEDIR/sem*"
      PASSLOG=./log/sempasslog
      FAILLOG=./log/semfaillog           
	;;
  THR) echo "Executing threads tests"
      SEARCH_DIR="$BASEDIR/pthread_*"
      PASSLOG=./log/thrpasslog
      FAILLOG=./log/thrfaillog           
	;;
  TMR) echo "Executing timers and clocks tests"
      SEARCH_DIR="$BASEDIR/time* $BASEDIR/*time $BASEDIR/clock* $BASEDIR/nanosleep"
      PASSLOG=./log/tmrpasslog
      FAILLOG=./log/tmrfaillog           
	;;
  MSG) echo "Executing message queues tests"
      SEARCH_DIR="$BASEDIR/mq_*"
      PASSLOG=./log/msgpasslog
      FAILLOG=./log/msgfaillog           
	;;
  TPS) echo "Executing process and thread scheduling tests"
      SEARCH_DIR="$BASEDIR/*sched*"
      PASSLOG=./log/tpspasslog
      FAILLOG=./log/tpsfaillog           
	;;
  MEM) echo "Executing mapped, process and shared memory tests"
      SEARCH_DIR="$BASEDIR/m*lock* $BASEDIR/m*map $BASEDIR/shm_*"
      PASSLOG=./log/mempasslog
      FAILLOG=./log/memfaillog           
	;;
  STR) echo "Executing mapped, stress tests"
      SEARCH_DIR=./empty
      STRESS_DIR=./stress
      PASSLOG=./log/stresspasslog
      FAILLOG=./log/stressfaillog           
	;;      
  ALL) echo "Executing mapped, all of conformance tests"
      SEARCH_DIR=./conformance
      PASSLOG=./log/passlog
      FAILLOG=./log/faillog           
	;;      
  *)	usage
	exit 1
	;;
esac
FINDFILESsh=$(find $(echo "$STRESS_DIR") -name '*-*.sh' -print)
FINDFILES=$(find $(echo "$SEARCH_DIR") -name '*.test' -print | grep -v core)
NEWSTR=`echo $FINDFILES $FINDFILESsh`
if [ -f $PASSLOG ]
then
      rm $PASSLOG
fi
if [ -f $FAILLOG ]
then
      rm $FAILLOG
fi
# Main program

start_func
PM_TO_AM=`date +%P`
if [ $PM_TO_AM  = "pm" ]
then
      COUNT=1
fi
echo "Run the conformance tests"
echo "=========================================="

count=1
while $TRUE
do
      FILE=`echo "$NEWSTR" | cut -f$count -d" "`
      if [ -z "$FILE" ]
      then
            PM_TO_AM=$(date +%P)
            if [ $PM_TO_AM = "am" ]
            then
                  COUNT=$(($COUNT+1))
            fi         
            if [ "$COUNT" = "2" ]
            then
                  end_func
            else

                  end_func_noday_change
            fi
            echo
            echo  "***************************"
            echo  "CONFORMANCE TEST RESULTS"
            echo  "***************************"
            echo  "* TOTAL:   $TOTAL "
            echo  "* PASSED:  $PASS "
            echo  "* FAILED:  $FAIL "
            echo  "* UNRESOLVED:  $UNRES "
            echo  "* UNSUPPORTED:  $UNSUP "
            echo  "* UNTESTED:  $UNTEST "
            echo  "* INTERRUPTED:  $INTR "
            echo  "* HUNG:  $HUNG "
            echo  "* SEGV:  $SEGV "  
            echo  "* OTHERS:  $OTH " 
            echo  "***************************\n"
            echo >> $PASSLOG
            echo  "***************************" >> $PASSLOG
            echo  "CONFORMANCE TEST RESULTS" >> $PASSLOG
            echo  "***************************" >> $PASSLOG
            echo  "* TOTAL:   $TOTAL " >> $PASSLOG
            echo  "* PASSED:  $PASS " >> $PASSLOG
            echo  "* FAILED:  $FAIL " >> $PASSLOG
            echo  "* UNRESOLVED:  $UNRES " >> $PASSLOG
            echo  "* UNSUPPORTED:  $UNSUP " >> $PASSLOG
            echo  "* UNTESTED:  $UNTEST " >> $PASSLOG
            echo  "* INTERRUPTED:  $INTR " >> $PASSLOG
            echo  "* HUNG:  $HUNG " >> $PASSLOG
            echo  "* SEGV:  $SEGV " >> $PASSLOG  
            echo  "* OTHERS:  $OTH " >> $PASSLOG 
            echo  "***************************\n" >> $PASSLOG            
            display_func
            echo "Finished"
            exit

      elif [ -x $FILE ]
      then
            FILEcut=`echo $FILE | cut -b3-80`
            TOTAL=$(($TOTAL+1))
            ./t0 $TIMEOUT_VAL $FILE > /dev/null 2>&1
            RET_VAL=$?
            if [ $RET_VAL -gt 5  -a  $RET_VAL -ne $TIMEVAL_RET ]
            then 
                  INTR_VAL=10
            fi 
            case $RET_VAL in

            0) 
                  PASS=$(($PASS+1))
                  echo  "$FILEcut:execution:PASS "
                  echo  "$FILEcut:execution:PASS " >> $PASSLOG
                  ;;
            1)     
                  FAIL=$(($FAIL+1))
                  echo  "$FILEcut:execution:FAIL "
                  echo  "$FILEcut:execution:FAIL " >> $FAILLOG
                  ;;

            
            255)     
                  FAIL=$(($FAIL+1))
                  echo  "$FILEcut:execution:FAIL "
                  echo  "$FILEcut:execution:FAIL " >> $FAILLOG
                  ;;


            2)
                  UNRES=$(($UNRES+1))
                  echo  "$FILEcut:execution:UNRESOLVED "
                  echo  "$FILEcut:execution:UNRESOLVED " >> $FAILLOG
                  ;;

            3)
                  ;;

            4)
                  UNSUP=$(($UNSUP+1))
                  echo  "$FILEcut:execution:UNSUPPORTED "
                  echo  "$FILEcut:execution:UNSUPPORTED " >> $FAILLOG                  
                  ;;

            5)
                  UNTEST=$(($UNTEST+1))
                  echo  "$FILEcut:execution:UNTESTED "
                  echo  "$FILEcut:execution:UNTESTED " >> $FAILLOG  
                  ;;

            10) 
                  INTR=$(($INTR+1))
                  echo  "$FILEcut:execution:INTERRUPTED "
                  echo  "$FILEcut:execution:INTERRUPTED " >> $FAILLOG                   
                  ;;

            $TIMEVAL_RET)
                        HUNG=$(($HUNG+1))     
                        echo  "$FILEcut:execution:HUNG "
                        echo  "$FILEcut:execution:HUNG " >> $FAILLOG                            
                        ;;
            139)
                  SEGV=$(($SEGV+1))
                  echo "$FILEcut:execution:Segmentaion Fault "
                  echo  "$FILEcut:execution:Segmentaion Fault " >> $FAILLOG                     
                  ;;
                  
            *)
                  OTH=$(($OTH+1))
                  echo "OTHERS: RET_VAL for $FILE : $RET_VAL"
                  echo  "OTHERS: RET_VAL for $FILE : $RET_VAL" >> $FAILLOG                    
                  ;;
            esac
      fi
      count=$(($count+1))
done


######################################################################################
 


