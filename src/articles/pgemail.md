---
title: "E-Mail notifications with attachments using Oracle PL/SQL"
description: " "
tags:
  - priority executor
  - Java
date: 2016-07-27
---
![PGNotifier](/static/images/email-logo.webp)

How to send eMail notifications using PL/SQL? I know this has been answered several times before. So what’s new here? Following is:

- Complete stand alone component
- Completely compatible with MIME standards
- Can send email as ‘To’ and ‘Cc’
- Can send mail to more than one recipient
- Can send mail with HTML message
- Complete mail sending functionality along with CLOB and BLOB attachments
- Can be used to send attachments as selected from database tables itself.
- Can send mail with more than one mail attachments
- Does not create any files on Oracle server for sending attachments
- Absolutely ready-to-use for calling from any Oracle PL/SQL code

Spec & Data Structures used are:

{% downloadsourcefilenote %}
<pre id="PG_NOTIFIER_spec" data-src="/static/plsql/PG_NOTIFIER_spec.plsql" data-download-link data-line="4-25,35-53"></pre>

Line numbers [4-25](#PG_NOTIFIER_spec.4-25) specify the data structures to be used :

**NOTIFICATION_RECIPIENTS** is a pl/sql array, that stores strings, used to hold email ids to which mail is to be sent.

**MAIL_ATTACHMENT_CLOB** is a record type used to hold information about One CLOB attachment. It holds information about attachment name, attachment data, attachment mime type (like txt, csv etc) and attachment character set.

**ARRAY_MAIL_ATTACHMENT_CLOB** is a pl/sql array that stores MAIL_ATTACHMENT_CLOB. It is essentially used to hold and send CLOB attachments.

**MAIL_ATTACHMENT_ BLOB** is a record type used to hold information about One BLOB attachment. It holds information about attachment name, attachment data and attachment mime type (like pdf, xls etc).

**ARRAY_MAIL_ATTACHMENT_BLOB** is a pl/sql array that stores MAIL_ATTACHMENT_BLOB. It is essentially used to hold and send CLOB attachments.

Line numbers [35-53](#PG_NOTIFIER_spec.35-53) specify the main procedures that can be called by an external procedure.

Procedure **SET_BASE64** is used to on/off base64 for BLOB attachments as some SMTP servers may not support encoding other than 7bit ASCII.

Procedure **NOTIFY** is the main procedure that is used to send mails. Following is the explanation of each of its parameters:

**P_MAILHOST** :- Host name or IP of the SMTP server

**P_MAILPORT** :- SMTP server port

**P_SENDER** :- Valid email id of the mail sender. Valid here means correct format but not necessarily correct id; like “first.last” is invalid but “first.last@unknown.com” is valid.

**P_TO_RECIPIENTS** :- PL/SQL array of email ids of all the ‘To’ recipients of the mail.

**P_SUBJECT** :- Mail subject

**P_MESSAGE_TEXT** :- Optional Text message.

**P_MESSAGE_HTML** :- Optional HTML message.

**P_ATTACHMENTS_CLOB** :- Optional PL/SQL array of CLOB attachments.

**P_ATTACHMENTS_BLOB** :- Optional PL/SQL array of BLOB attachments.

**P_CC_RECIPIENTS** :- Optional PL/SQL array of email ids of all the ‘Cc’ recipients of the mail

Implementation/body of above spec will be like this:

{% downloadsourcefilenote %}
<pre data-src="/static/plsql/PG_NOTIFIER_body.plsql" data-download-link data-range="1,11"></pre>


Now for some examples:

Sending a plain text message:

```plsql
BEGIN
PG_NOTIFIER.NOTIFY (
P_MAILHOST => ‘some.smtp.server.com’
, P_MAILPORT => 25
, P_SENDER => ‘someone@something.com’
, P_TO_RECIPIENTS => PG_NOTIFIER.NOTIFICATION_RECIPIENTS(‘some1@some.com’, ‘some2@some.com’)
, P_SUBJECT => ‘subject’
, P_MESSAGE_TEXT => ‘some text’
);
END;
```

Sending a plain text mail with Cc:

```plsql
BEGIN
PG_NOTIFIER.NOTIFY (
PG_NOTIFIER.P_MAILHOST => ‘some.smtp.server.com’
, P_MAILPORT => 25
, P_SENDER => ‘someone@something.com’
, P_TO_RECIPIENTS => PG_NOTIFIER.NOTIFICATION_RECIPIENTS(‘some1@some.com’, ‘some2@some.com’)
, P_SUBJECT => ‘subject’
, P_MESSAGE_TEXT => ‘some text’
, P_CC_RECIPIENTS => PG_NOTIFIER.NOTIFICATION_RECIPIENTS(‘some3@some.com’, ‘some4@some.com’)
);
END;
```

Sending a mail with HTML message:

```plsql
DECLARE
HTML_MESSAGE CLOB;
BEGIN
/*
* WRITE CODE TO GENERATE HTML MESSAGE
*/
PG_NOTIFIER.NOTIFY (
P_MAILHOST => ‘some.smtp.server.com’
, P_MAILPORT => 25
, P_SENDER => ‘someone@something.com’
, P_TO_RECIPIENTS => PG_NOTIFIER.NOTIFICATION_RECIPIENTS(‘some1@some.com’, ‘some2@some.com’)
, P_SUBJECT => ‘subject’
, P_MESSAGE_TEXT => ‘some text’
, P_MESSAGE_HTML => HTML_MESSAGE
, P_CC_RECIPIENTS => PG_NOTIFIER.NOTIFICATION_RECIPIENTS(‘some3@some.com’, ‘some4@some.com’)
);
END;
```

Sending mail with CLOB attachments:

```plsql
DECLARE
CLOB_ATTACH_ARRAY PG_NOTIFIER.ARRAY_MAIL_ATTACHMENT_CLOB := PG_NOTIFIER.ARRAY_MAIL_ATTACHMENT_CLOB();
CLOB_ATTACH1 PG_NOTIFIER.MAIL_ATTACHMENT_CLOB;
CLOB_ATTACH2 PG_NOTIFIER.MAIL_ATTACHMENT_CLOB;
CLOB_DATA1 CLOB;
CLOB_DATA2 CLOB;
 
BEGIN
 
/*
 *GET CLOB DATA INTO CLOB_DATA1
 */
 
CLOB_ATTACH1.ATTACHMENT_FILE_NAME := ‘ATTACH1’;
CLOB_ATTACH1.ATTACHMENT_DATA := CLOB_DATA1;
CLOB_ATTACH1.ATTACHMENT_MIME_TYPE := ‘TYPE1’;
CLOB_ATTACH1.ATTACHMENT_CHARSET := ‘CHRSET1’;
CLOB_ATTACH_ARRAY.EXTEND(1);
CLOB_ATTACH_ARRAY(CLOB_ATTACH_ARRAY.COUNT()) := CLOB_ATTACH1;
 
/*
 *GET CLOB DATA INTO CLOB_DATA2
 */
 
CLOB_ATTACH2.ATTACHMENT_FILE_NAME := ‘ATTACH2’;
CLOB_ATTACH2.ATTACHMENT_DATA := CLOB_DATA2;
CLOB_ATTACH2.ATTACHMENT_MIME_TYPE := ‘TYPE2’;
CLOB_ATTACH2.ATTACHMENT_CHARSET := ‘CHRSET2’;
CLOB_ATTACH_ARRAY.EXTEND(1);
CLOB_ATTACH_ARRAY(CLOB_ATTACH_ARRAY.COUNT()) := CLOB_ATTACH2;
 
/*
 *Attach as many as.
 */
 
PG_NOTIFIER.NOTIFY (
P_MAILHOST => ‘some.smtp.server.com’
, P_MAILPORT => 25
, P_SENDER => ‘someone@something.com’
, P_TO_RECIPIENTS => PG_NOTIFIER.NOTIFICATION_RECIPIENTS(‘some1@some.com’, ‘some2@some.com’)
, P_SUBJECT => ‘subject’
, P_MESSAGE_TEXT => ‘some text’
, P_ATTACHMENTS_CLOB => CLOB_ATTACH_ARRAY
, P_CC_RECIPIENTS => PG_NOTIFIER.NOTIFICATION_RECIPIENTS(‘some3@some.com’, ‘some4@some.com’)
);
END;
```

Sending Mail with BLOB attachments:

```plsql
DECLARE
BLOB_ATTACH_ARRAY PG_NOTIFIER.ARRAY_MAIL_ATTACHMENT_BLOB := ARRAY_MAIL_ATTACHMENT_BLOB();
BLOB_ATTACH1 PG_NOTIFIER.MAIL_ATTACHMENT_BLOB;
BLOB_ATTACH2 PG_NOTIFIER.MAIL_ATTACHMENT_BLOB;
BLOB_DATA1 BLOB;
BLOB_DATA2 BLOB;
 
BEGIN
 
/*
 *GET CLOB DATA INTO BLOB_DATA1
 */
 
BLOB_ATTACH1.ATTACHMENT_FILE_NAME := ‘ATTACH1’;
BLOB_ATTACH1.ATTACHMENT_DATA := BLOB_DATA1;
BLOB_ATTACH1.ATTACHMENT_MIME_TYPE := ‘TYPE1’;
BLOB_ATTACH_ARRAY.EXTEND(1);
BLOB_ATTACH_ARRAY(BLOB_ATTACH_ARRAY.COUNT()) := BLOB_ATTACH1;
 
/*
 *GET CLOB DATA INTO BLOB_DATA2
 */
 
BLOB_ATTACH2.ATTACHMENT_FILE_NAME := ‘ATTACH2’;
BLOB_ATTACH2.ATTACHMENT_DATA := BLOB_DATA2;
BLOB_ATTACH2.ATTACHMENT_MIME_TYPE := ‘TYPE2’;
BLOB_ATTACH_ARRAY.EXTEND(1);
BLOB_ATTACH_ARRAY(BLOB_ATTACH_ARRAY.COUNT()) := BLOB_ATTACH2;
 
/*
 *Attach as many as.
 */
 
PG_NOTIFIER.NOTIFY (
P_MAILHOST => ‘some.smtp.server.com’
, P_MAILPORT => 25
, P_SENDER => ‘someone@something.com’
, P_TO_RECIPIENTS => PG_NOTIFIER.NOTIFICATION_RECIPIENTS(‘some1@some.com’, ‘some2@some.com’)
, P_SUBJECT => ‘subject’
, P_MESSAGE_TEXT => ‘some text’
, P_ATTACHMENTS_BLOB => BLOB_ATTACH_ARRAY
, P_CC_RECIPIENTS => PG_NOTIFIER.NOTIFICATION_RECIPIENTS(‘some3@some.com’, ‘some4@some.com’)
);
END;
```

Sending mail with both BLOB and CLOB attachments:

```plsql
DECLARE
CLOB_ATTACH_ARRAY PG_NOTIFIER.ARRAY_MAIL_ATTACHMENT_CLOB := PG_NOTIFIER.ARRAY_MAIL_ATTACHMENT_CLOB();
CLOB_ATTACH1 PG_NOTIFIER.MAIL_ATTACHMENT_CLOB;
CLOB_ATTACH2 PG_NOTIFIER.MAIL_ATTACHMENT_CLOB;
CLOB_DATA1 CLOB;
CLOB_DATA2 CLOB;
 
BLOB_ATTACH_ARRAY PG_NOTIFIER.ARRAY_MAIL_ATTACHMENT_BLOB := ARRAY_MAIL_ATTACHMENT_BLOB();
BLOB_ATTACH1 PG_NOTIFIER.MAIL_ATTACHMENT_BLOB;
BLOB_ATTACH2 PG_NOTIFIER.MAIL_ATTACHMENT_BLOB;
BLOB_DATA1 BLOB;
BLOB_DATA2 BLOB;
 
BEGIN
 
/*
 *GET CLOB DATA INTO CLOB_DATA1
 */
 
CLOB_ATTACH1.ATTACHMENT_FILE_NAME := ‘ATTACH1’;
CLOB_ATTACH1.ATTACHMENT_DATA := CLOB_DATA1;
CLOB_ATTACH1.ATTACHMENT_MIME_TYPE := ‘TYPE1’;
CLOB_ATTACH1.ATTACHMENT_CHARSET := ‘CHRSET1’;
CLOB_ATTACH_ARRAY.EXTEND(1);
CLOB_ATTACH_ARRAY(CLOB_ATTACH_ARRAY.COUNT()) := CLOB_ATTACH1;
 
/*
 *GET CLOB DATA INTO CLOB_DATA2
 */
 
CLOB_ATTACH2.ATTACHMENT_FILE_NAME := ‘ATTACH2’;
CLOB_ATTACH2.ATTACHMENT_DATA := CLOB_DATA2;
CLOB_ATTACH2.ATTACHMENT_MIME_TYPE := ‘TYPE2’;
CLOB_ATTACH2.ATTACHMENT_CHARSET := ‘CHRSET2’;
CLOB_ATTACH_ARRAY.EXTEND(1);
CLOB_ATTACH_ARRAY(CLOB_ATTACH_ARRAY.COUNT()) := CLOB_ATTACH2;
 
/*
 *Attach as many as CLOB.
 */
 
/*
 *GET CLOB DATA INTO BLOB_DATA1
 */
 
BLOB_ATTACH1.ATTACHMENT_FILE_NAME := ‘ATTACH1’;
BLOB_ATTACH1.ATTACHMENT_DATA := BLOB_DATA1;
BLOB_ATTACH1.ATTACHMENT_MIME_TYPE := ‘TYPE1’;
BLOB_ATTACH_ARRAY.EXTEND(1);
BLOB_ATTACH_ARRAY(BLOB_ATTACH_ARRAY.COUNT()) := BLOB_ATTACH1;
 
/*
 *GET CLOB DATA INTO BLOB_DATA2
 */
 
BLOB_ATTACH2.ATTACHMENT_FILE_NAME := ‘ATTACH2’;
BLOB_ATTACH2.ATTACHMENT_DATA := BLOB_DATA2;
BLOB_ATTACH2.ATTACHMENT_MIME_TYPE := ‘TYPE2’;
BLOB_ATTACH_ARRAY.EXTEND(1);
BLOB_ATTACH_ARRAY(BLOB_ATTACH_ARRAY.COUNT()) := BLOB_ATTACH2;
 
/*
 *Attach as many as BLOB.
 */
 
PG_NOTIFIER.NOTIFY (
P_MAILHOST => ‘some.smtp.server.com’
, P_MAILPORT => 25
, P_SENDER => ‘someone@something.com’
, P_TO_RECIPIENTS => PG_NOTIFIER.NOTIFICATION_RECIPIENTS(‘some1@some.com’, ‘some2@some.com’)
, P_SUBJECT => ‘subject’
, P_MESSAGE_TEXT => ‘some text’
, P_ATTACHMENTS_CLOB => CLOB_ATTACH_ARRAY
, P_ATTACHMENTS_BLOB => BLOB_ATTACH_ARRAY
, P_CC_RECIPIENTS => PG_NOTIFIER.NOTIFICATION_RECIPIENTS(‘some3@some.com’, ‘some4@some.com’)
);
END;
```