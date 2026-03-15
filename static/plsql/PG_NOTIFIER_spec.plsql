CREATE OR REPLACE PACKAGE PG_NOTIFIER
AS
	--an array to store email addresses who needs to be notified
    TYPE NOTIFICATION_RECIPIENTS IS VARRAY (32767) OF VARCHAR (32767);

    --record to store info for a clob attachment
    TYPE MAIL_ATTACHMENT_CLOB IS RECORD (
        ATTACHMENT_FILE_NAME          VARCHAR2 (200)
      , ATTACHMENT_DATA               CLOB
      , ATTACHMENT_MIME_TYPE          VARCHAR2 (20)
      , ATTACHMENT_CHARSET            VARCHAR2 (20)
    );

    --array to store clob attachment records
    TYPE ARRAY_MAIL_ATTACHMENT_CLOB IS VARRAY (32767) OF MAIL_ATTACHMENT_CLOB;

    --record to store info for a blob attachment
    TYPE MAIL_ATTACHMENT_BLOB IS RECORD (
        ATTACHMENT_FILE_NAME          VARCHAR2 (200)
      , ATTACHMENT_DATA               BLOB
      , ATTACHMENT_MIME_TYPE          VARCHAR2 (20)
    );

    --array to store blob attachment records
    TYPE ARRAY_MAIL_ATTACHMENT_BLOB IS VARRAY (32767) OF MAIL_ATTACHMENT_BLOB;

    --custom exception for all errors in mail sending
    MAIL_SENDING_ERROR EXCEPTION;
	  MAIL_SENDING_ERROR_CODE CONSTANT PLS_INTEGER := -20001;
    PRAGMA EXCEPTION_INIT (MAIL_SENDING_ERROR, -20001);

    /*
    procedure to set base64 encoding on/off for blob attachments
    */
    PROCEDURE SET_BASE64_ENCODING (
        VAL                                BOOLEAN
    );

    /*
    Procedure to send notifications
    */
    PROCEDURE NOTIFY (
        P_MAILHOST                IN       VARCHAR2   --SMTP server IP or DNS
      , P_MAILPORT                IN       NUMBER   --SMTP server port
      , P_SENDER                  IN       VARCHAR2   --sender email address
      , P_TO_RECIPIENTS           IN       NOTIFICATION_RECIPIENTS   --array of 'To' notification recipients
      , P_SUBJECT                 IN       VARCHAR2   --mail subject
      , P_MESSAGE_TEXT            IN       VARCHAR2 DEFAULT NULL   --text message
      , P_MESSAGE_HTML            IN       CLOB DEFAULT NULL   --html message
      , P_ATTACHMENTS_CLOB        IN       ARRAY_MAIL_ATTACHMENT_CLOB DEFAULT NULL   --array of clob attachmets
      , P_ATTACHMENTS_BLOB        IN       ARRAY_MAIL_ATTACHMENT_BLOB DEFAULT NULL   --array of blob attachmets
      , P_CC_RECIPIENTS           IN       NOTIFICATION_RECIPIENTS DEFAULT NULL   --array of 'CC' notification recipients
    );
END PG_NOTIFIER;
/
