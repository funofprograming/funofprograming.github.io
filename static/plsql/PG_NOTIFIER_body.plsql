CREATE OR REPLACE PACKAGE BODY PG_NOTIFIER
AS
    G_MIME_BOUNDARY      CONSTANT VARCHAR2 (50) := 'asdfghjklpoiuytrewqzxcvbnm';
    G_MIME_BOUNDARY_FIRST CONSTANT VARCHAR2 (50) := '--' || G_MIME_BOUNDARY;
    G_MIME_BOUNDARY_LAST CONSTANT VARCHAR2 (50) := '--' || G_MIME_BOUNDARY || '--';
    G_BASE64_ENCODING             BOOLEAN := FALSE;

    --index-by-table of RAW type. used for converting CLOB/BLOB to RAW
    TYPE MAIL_ATTACHMENT_RAW IS TABLE OF RAW (32767)
        INDEX BY PLS_INTEGER;
/*PROFILER(20): associative array is Oracle 9.2.0 */

    /*
    Procedure to set base64 encoding on/off
    */
    PROCEDURE SET_BASE64_ENCODING (
        VAL                                BOOLEAN
    )
    IS
    BEGIN
        G_BASE64_ENCODING          := VAL;
    END SET_BASE64_ENCODING;

    /*
     *Function to convert CLOB into MAIL_ATTACHMENT_RAW
     */
    FUNCTION CONVERT_CLOB_TO_RAW (
        P_INPUT                   IN       CLOB
    )
        RETURN MAIL_ATTACHMENT_RAW
    IS
        V_BUFFER_SIZE        CONSTANT NUMBER := 32767;
        V_OFFSET                      NUMBER := 1;
        V_INPUT_LEN                   NUMBER;
        V_OUTPUT                      MAIL_ATTACHMENT_RAW;
        V_COUNTER                     NUMBER := 1;
    BEGIN
        V_OUTPUT.DELETE;
        V_INPUT_LEN                := DBMS_LOB.GETLENGTH (P_INPUT);

        WHILE V_OFFSET < V_INPUT_LEN LOOP
            IF V_OFFSET + V_BUFFER_SIZE < V_INPUT_LEN THEN
                V_OUTPUT (V_COUNTER)       := UTL_RAW.CAST_TO_RAW (DBMS_LOB.SUBSTR (
                                                     P_INPUT
                                                   , V_BUFFER_SIZE
                                                   , V_OFFSET
                                                 ) );
            ELSE
                V_OUTPUT (V_COUNTER)       :=
                                 UTL_RAW.CAST_TO_RAW (DBMS_LOB.SUBSTR (
                                         P_INPUT
                                       , V_INPUT_LEN - V_OFFSET + 1
                                       , V_OFFSET
                                     ) );
            END IF;

            V_OFFSET                   := V_OFFSET + V_BUFFER_SIZE;
            V_COUNTER                  := V_COUNTER + 1;
        END LOOP;

        RETURN V_OUTPUT;
    END CONVERT_CLOB_TO_RAW;

    /*
     *Function to convert BLOB into MAIL_ATTACHMENT_RAW
     */
    FUNCTION CONVERT_BLOB_TO_RAW (
        P_INPUT                   IN       BLOB
    )
        RETURN MAIL_ATTACHMENT_RAW
    IS
        V_BUFFER_SIZE        CONSTANT NUMBER := 32767;
        V_OFFSET                      NUMBER := 1;
        V_INPUT_LEN                   NUMBER;
        V_OUTPUT                      MAIL_ATTACHMENT_RAW;
        V_COUNTER                     NUMBER := 1;
    BEGIN
        V_OUTPUT.DELETE;
        V_INPUT_LEN                := DBMS_LOB.GETLENGTH (P_INPUT);

        IF G_BASE64_ENCODING = TRUE THEN
            WHILE V_OFFSET < V_INPUT_LEN LOOP
                IF V_OFFSET + V_BUFFER_SIZE < V_INPUT_LEN THEN
                    V_OUTPUT (V_COUNTER)       :=
                                         UTL_ENCODE.BASE64_ENCODE (DBMS_LOB.SUBSTR (
                                                 P_INPUT
                                               , V_BUFFER_SIZE
                                               , V_OFFSET
                                             ) );
                ELSE
                    V_OUTPUT (V_COUNTER)       :=
                            UTL_ENCODE.BASE64_ENCODE (DBMS_LOB.SUBSTR (
                                    P_INPUT
                                  , V_INPUT_LEN - V_OFFSET + 1
                                  , V_OFFSET
                                ) );
                END IF;

                V_OFFSET                   := V_OFFSET + V_BUFFER_SIZE;
                V_COUNTER                  := V_COUNTER + 1;
            END LOOP;
        ELSE
            WHILE V_OFFSET < V_INPUT_LEN LOOP
                IF V_OFFSET + V_BUFFER_SIZE < V_INPUT_LEN THEN
                    V_OUTPUT (V_COUNTER)       := DBMS_LOB.SUBSTR (
                                                     P_INPUT
                                                   , V_BUFFER_SIZE
                                                   , V_OFFSET
                                                 );
                ELSE
                    V_OUTPUT (V_COUNTER)       := DBMS_LOB.SUBSTR (
                                                     P_INPUT
                                                   , V_INPUT_LEN - V_OFFSET + 1
                                                   , V_OFFSET
                                                 );
                END IF;

                V_OFFSET                   := V_OFFSET + V_BUFFER_SIZE;
                V_COUNTER                  := V_COUNTER + 1;
            END LOOP;
        END IF;

        RETURN V_OUTPUT;
    END CONVERT_BLOB_TO_RAW;

    /*
    Procedure to send notifications
    */
    PROCEDURE NOTIFY (
        P_MAILHOST                IN       VARCHAR2
      , P_MAILPORT                IN       NUMBER
      , P_SENDER                  IN       VARCHAR2
      , P_TO_RECIPIENTS           IN       NOTIFICATION_RECIPIENTS
      , P_SUBJECT                 IN       VARCHAR2
      , P_MESSAGE_TEXT            IN       VARCHAR2
      , P_MESSAGE_HTML            IN       CLOB DEFAULT NULL
      , P_ATTACHMENTS_CLOB        IN       ARRAY_MAIL_ATTACHMENT_CLOB DEFAULT NULL
      , P_ATTACHMENTS_BLOB        IN       ARRAY_MAIL_ATTACHMENT_BLOB DEFAULT NULL
      , P_CC_RECIPIENTS           IN       NOTIFICATION_RECIPIENTS DEFAULT NULL
    )
    IS
        V_CONNECTION                  UTL_SMTP.CONNECTION;
        V_MAIL_HEADER                 VARCHAR2 (1000);
        V_SMTP_REPLY                  UTL_SMTP.REPLY;
        V_SYSTEM_MAIL_NOTE            VARCHAR2 (1000) := '*Note: This is a system generated mail. Please do not reply.';
        V_MESSAGE                     VARCHAR2 (1000) := P_MESSAGE_TEXT;
        V_MESSAGE_HTML                VARCHAR2 (1000) := P_MESSAGE_HTML;
        V_MIME_HEADER                 VARCHAR2 (32767);
        V_ATTACHMENT_CLOB             MAIL_ATTACHMENT_CLOB := NULL;
        V_ATTACHMENT_BLOB             MAIL_ATTACHMENT_BLOB := NULL;
        V_RAW_ATTACH                  MAIL_ATTACHMENT_RAW;
    BEGIN
        -- Start the connection.
        V_SMTP_REPLY               := UTL_SMTP.OPEN_CONNECTION (
                                         P_MAILHOST
                                       , P_MAILPORT
                                       , V_CONNECTION
                                     );
        --generate header
        V_MAIL_HEADER              :=
               'Date: '
            || TO_CHAR (SYSDATE, 'dd/Mon/yyyy hh:mi:ss AM')
            || UTL_TCP.CRLF
            || 'From: '
            || P_SENDER
            || ''
            || UTL_TCP.CRLF
            || 'Subject: '
            || P_SUBJECT
            || UTL_TCP.CRLF
            || 'To: ';

        FOR I IN 1 .. P_TO_RECIPIENTS.COUNT LOOP
            V_MAIL_HEADER              := V_MAIL_HEADER || P_TO_RECIPIENTS (I) || ';';
        END LOOP;

        V_MAIL_HEADER              := V_MAIL_HEADER || UTL_TCP.CRLF;

        IF P_CC_RECIPIENTS IS NOT NULL THEN
            --cc recipients found
            V_MAIL_HEADER              := V_MAIL_HEADER || 'Cc: ';

            FOR I IN 1 .. P_CC_RECIPIENTS.COUNT LOOP
                V_MAIL_HEADER              := V_MAIL_HEADER || P_CC_RECIPIENTS (I) || ';';
            END LOOP;

            V_MAIL_HEADER              := V_MAIL_HEADER || UTL_TCP.CRLF;
        END IF;

        -- Handshake with the SMTP server
        V_SMTP_REPLY               := UTL_SMTP.HELO (V_CONNECTION, P_MAILHOST);
        V_SMTP_REPLY               := UTL_SMTP.MAIL (V_CONNECTION, P_SENDER);

        FOR I IN 1 .. P_TO_RECIPIENTS.COUNT LOOP
            UTL_SMTP.RCPT (V_CONNECTION, P_TO_RECIPIENTS (I) );
        END LOOP;

        IF P_CC_RECIPIENTS IS NOT NULL THEN
            FOR I IN 1 .. P_CC_RECIPIENTS.COUNT LOOP
                UTL_SMTP.RCPT (V_CONNECTION, P_CC_RECIPIENTS (I) );
            END LOOP;
        END IF;

        UTL_SMTP.OPEN_DATA (V_CONNECTION);
        UTL_SMTP.WRITE_DATA (V_CONNECTION, V_MAIL_HEADER);
        --GENERATING MIME HEADER
        V_MIME_HEADER              := V_MIME_HEADER || 'MIME-Version: 1.0' || UTL_TCP.CRLF;
        V_MIME_HEADER              :=
                  V_MIME_HEADER || 'Content-type: multipart/mixed; boundary="' || G_MIME_BOUNDARY || '"' || UTL_TCP.CRLF;
        UTL_SMTP.WRITE_DATA (V_CONNECTION, V_MIME_HEADER);

        --WRITING TEXT MESSAGE
        IF V_MESSAGE IS NOT NULL THEN
            V_MIME_HEADER              := G_MIME_BOUNDARY_FIRST || UTL_TCP.CRLF;
            V_MIME_HEADER              := V_MIME_HEADER || 'Content-type: text/plain;' || UTL_TCP.CRLF;
            V_MESSAGE                  := UTL_TCP.CRLF || V_MESSAGE || UTL_TCP.CRLF;
            UTL_SMTP.WRITE_DATA (V_CONNECTION, V_MIME_HEADER);
            UTL_SMTP.WRITE_DATA (V_CONNECTION, V_MESSAGE);
        END IF;

        --WRITING HTML MESSAGE
        IF V_MESSAGE_HTML IS NOT NULL THEN
            V_MIME_HEADER              := G_MIME_BOUNDARY_FIRST || UTL_TCP.CRLF;
            V_MIME_HEADER              := V_MIME_HEADER || 'Content-type: text/html;' || UTL_TCP.CRLF;
            V_MESSAGE_HTML             := UTL_TCP.CRLF || V_MESSAGE_HTML || UTL_TCP.CRLF;
            UTL_SMTP.WRITE_DATA (V_CONNECTION, V_MIME_HEADER);
            V_RAW_ATTACH               := CONVERT_CLOB_TO_RAW (V_MESSAGE_HTML);

            FOR RAW_COUNTER IN V_RAW_ATTACH.FIRST .. V_RAW_ATTACH.LAST LOOP
                UTL_SMTP.WRITE_RAW_DATA (V_CONNECTION, V_RAW_ATTACH (RAW_COUNTER) );
            END LOOP;
        END IF;

        UTL_SMTP.WRITE_DATA (V_CONNECTION, UTL_TCP.CRLF || UTL_TCP.CRLF || V_SYSTEM_MAIL_NOTE);
        UTL_SMTP.WRITE_DATA (V_CONNECTION, UTL_TCP.CRLF);

        --PROCESSING CLOB ATTACHMENTS
        IF P_ATTACHMENTS_CLOB IS NOT NULL THEN
            FOR ATT_COUNTER IN 1 .. P_ATTACHMENTS_CLOB.COUNT () LOOP
                V_MIME_HEADER              := G_MIME_BOUNDARY_FIRST || UTL_TCP.CRLF;
                V_ATTACHMENT_CLOB          := P_ATTACHMENTS_CLOB (ATT_COUNTER);
                --GENERATE MIME HEADER
                V_MIME_HEADER              :=
                       V_MIME_HEADER
                    || 'Content-Disposition: attachment; filename='
                    || V_ATTACHMENT_CLOB.ATTACHMENT_FILE_NAME
                    || ';'
                    || UTL_TCP.CRLF;
                V_MIME_HEADER              :=
                       V_MIME_HEADER
                    || 'Content-type: '
                    || V_ATTACHMENT_CLOB.ATTACHMENT_MIME_TYPE
                    || '; name='
                    || V_ATTACHMENT_CLOB.ATTACHMENT_FILE_NAME
                    || '; charset='
                    || V_ATTACHMENT_CLOB.ATTACHMENT_CHARSET
                    || ';'
                    || UTL_TCP.CRLF;
                V_MIME_HEADER              := V_MIME_HEADER || 'Content-transfer-encoding: 7bit;' || UTL_TCP.CRLF;
                V_MIME_HEADER              := V_MIME_HEADER || UTL_TCP.CRLF;
                UTL_SMTP.WRITE_DATA (V_CONNECTION, V_MIME_HEADER);
                V_RAW_ATTACH               := CONVERT_CLOB_TO_RAW (V_ATTACHMENT_CLOB.ATTACHMENT_DATA);

                FOR RAW_COUNTER IN V_RAW_ATTACH.FIRST .. V_RAW_ATTACH.LAST LOOP
                    UTL_SMTP.WRITE_RAW_DATA (V_CONNECTION, V_RAW_ATTACH (RAW_COUNTER) );
                END LOOP;

                UTL_SMTP.WRITE_DATA (V_CONNECTION, UTL_TCP.CRLF);
            END LOOP;
        END IF;

        --PROCESSING BLOB ATTACHMENTS
        IF P_ATTACHMENTS_BLOB IS NOT NULL THEN
            FOR ATT_COUNTER IN 1 .. P_ATTACHMENTS_BLOB.COUNT () LOOP
                V_MIME_HEADER              := G_MIME_BOUNDARY_FIRST || UTL_TCP.CRLF;
                V_ATTACHMENT_BLOB          := P_ATTACHMENTS_BLOB (ATT_COUNTER);
                --GENERATE MIME HEADER
                V_MIME_HEADER              :=
                       V_MIME_HEADER
                    || 'Content-Disposition: attachment; filename='
                    || V_ATTACHMENT_BLOB.ATTACHMENT_FILE_NAME
                    || ';'
                    || UTL_TCP.CRLF;
                V_MIME_HEADER              :=
                       V_MIME_HEADER
                    || 'Content-type: '
                    || V_ATTACHMENT_BLOB.ATTACHMENT_MIME_TYPE
                    || '; name='
                    || V_ATTACHMENT_BLOB.ATTACHMENT_FILE_NAME
                    || ';'
                    || UTL_TCP.CRLF;

                IF G_BASE64_ENCODING = TRUE THEN
                    V_MIME_HEADER              := V_MIME_HEADER || 'Content-transfer-encoding: base64;' || UTL_TCP.CRLF;
                END IF;

                V_MIME_HEADER              := V_MIME_HEADER || UTL_TCP.CRLF;
                UTL_SMTP.WRITE_DATA (V_CONNECTION, V_MIME_HEADER);
                V_RAW_ATTACH               := CONVERT_BLOB_TO_RAW (V_ATTACHMENT_BLOB.ATTACHMENT_DATA);

                FOR RAW_COUNTER IN V_RAW_ATTACH.FIRST .. V_RAW_ATTACH.LAST LOOP
                    UTL_SMTP.WRITE_RAW_DATA (V_CONNECTION, V_RAW_ATTACH (RAW_COUNTER) );
                END LOOP;

                UTL_SMTP.WRITE_DATA (V_CONNECTION, UTL_TCP.CRLF);
            END LOOP;
        END IF;

        --write final boundary
        UTL_SMTP.WRITE_DATA (V_CONNECTION, G_MIME_BOUNDARY_LAST);
        --signal end of data. Mail actually sent at this point.
        UTL_SMTP.CLOSE_DATA (V_CONNECTION);
        --close connection with SMTP server
        UTL_SMTP.QUIT (V_CONNECTION);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR (MAIL_SENDING_ERROR_CODE, 'Mail Sending Failed' || UTL_TCP.CRLF || SQLERRM);
    END NOTIFY;
END PG_NOTIFIER;
/
