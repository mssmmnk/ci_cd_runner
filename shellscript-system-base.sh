#defining a function that checks command execution errors

check_error() { #the 'check_error' function deals with the execution results, aka, checks the return status of each command and exits the script if the command fails 
    if [ $? -ne 0 ]; then #'$' is a variable that stores the exit status of the last command, '-ne' is a conditional operator which means 'not equal to', '0' is the value that indicates that the command worked
                          # so : if the status is non-zero, an error will occur. Remembering that 0 represents the functional state of the command, that is, 0 = works
        echo "Error executing command. Exiting..." #echo = print 
        exit 1 
    fi #keyword for end of the statement (if)
}

##

for HOST in $REMOTE_HOST_SYSTEM
do
  echo "deploying to apache web server $HOST" #
  if ssh $REMOTE_USER@$HOST [[ -f $REMOTE_HOST_SYSTEM/files ]]
  then
    echo "removing old files..."
    ssh $REMOTE_USER@$HOST 'grep "^<" '"$REMOTE_PATH_SYSTEM'/files | cut -c xx- | sed '"'"'s@^@'$REMOTE_PATH_SYSTEM'/ordner/@g'"'"' | xargs -d "\n" rm -f'
  fi

  echo "copying files to remote host..."
  rsync -iar ./ordner/ordner2/ $REMOTE_USER@$HOST:$REMOTE_PATH_SYSTEM/ROOT/ | ssh $REMOTE_USER@$HOST "cat - > $REMOTE_PATH_SYSTEM/files"

  echo "modifying privileges of copied files..."
  ssh $REMOTE_USER@$HOST "chmod -R --silent o-w $REMOTE_PATH_SYSTEM/ROOT || true"

  echo "host deployed"
done

