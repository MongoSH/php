bash "install_openoffice" do
  user "root"
  cwd "/tmp"
  code <<-EOH

#!/bin/bash -x
#
# Description: This script gets ond installs openOffice
#
# Written by: Naresh Patel,  12/13/2011
#
# apt-get remove openoffice*.*

mkdir -p /ebs  #added to take care of Rackspace server

OO_INSTALL_LOG=/ebs/oo_install.log
>${OO_INSTALL_LOG}
OO_DIR=/ebs/openoffice
rm -Rf /ebs/openoffice
mkdir -p ${OO_DIR}
cd ${OO_DIR}

MTYPE="64bit"
uname -a|grep x86_64 >/dev/null
if [ $? -eq 0 ]; then
   MTYPE="64bit"
   DOWNLOAD_URL="http://devdepot.s3.amazonaws.com/OOo_3.3.0_Linux_x86-64_install-deb_en-US.tar.gz"
   INSTALL_FILE="OOo_3.3.0_Linux_x86-64_install-deb_en-US.tar.gz"
else
   MTYPE="32bit"
   DOWNLOAD_URL="http://devdepot.s3.amazonaws.com/OOo_3.3.0_Linux_x86_install-deb_en-US.tar.gz"
   INSTALL_FILE="OOo_3.3.0_Linux_x86_install-deb_en-US.tar.gz"
fi

# echo $DOWNLOAD_URL


INSTALL_DIR="OOO330_m20_native_packed-1_en-US.9567"

echo "Downloading OpenOffice" >> ${OO_INSTALL_LOG}
wget ${DOWNLOAD_URL}
if [ $? -eq 0 ]; then
   echo "Downloaded OpenOffice successfully" >> ${OO_INSTALL_LOG}

   tar xvfz ${INSTALL_FILE}
   if [ $? -eq 0 ]; then
       dpkg -i ${OO_DIR}/${INSTALL_DIR}/DEBS/*.deb
       if [ $? -eq 0 ]; then
           echo "Installed OpenOffice successfully" >> ${OO_INSTALL_LOG}
       else
           echo "Failed to install OpenOffice" >> ${OO_INSTALL_LOG}
       fi
   else
       echo "Failed to extract OpenOffice installation tar balln" >> ${OO_INSTALL_LOG}
   fi
else
   echo "Failed to download OpenOffice" >> ${OO_INSTALL_LOG}
fi

#
# Add a cron job to watch OpenOffice
#

cat <<"EOF"  > /etc/cron.hourly/mon-openoffice.sh
#!/bin/sh
netstat -an |grep 8100|grep LISTEN > /dev/null
if [ $? -ne 0 ]; then
  /opt/openoffice.org3/program/soffice.bin -headless -nofirststartwizard -accept="socket,host=localhost,port=8100;urp;StarOffice.Service"&
   date >> /tmp/mon_office.out
   echo "Was died - Restarted..." >> /tmp/mon_office.out
else
   date >> /tmp/mon_office.out
   echo "Running fine." >> /tmp/mon_office.out
fi
EOF

chmod +x /etc/cron.hourly/mon-openoffice.sh

/etc/cron.hourly/mon-openoffice.sh

service cron restart

exit 0



  EOH
end
