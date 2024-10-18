codeunit 70100 "AutoSendCustomerStatement"
{
    SingleInstance = true;

    trigger OnRun()
    var
        Customer: Record Customer;
        CustomerLedgerEntries: Record "Cust. Ledger Entry";
    begin
        EndDate := CALCDATE('CM+2M', WorkDate);
        txtEndDate := format(EndDate, 0, '<Year4>') + '-' + format(EndDate, 0, '<Month,2>') + '-' + format(EndDate, 0, '<Day,2>');
        StartDate := 20231001D;
        txtStartDate := format(StartDate, 0, '<Year4>') + '-' + format(StartDate, 0, '<Month,2>') + '-' + format(StartDate, 0, '<Day,2>');


        Customer.SetCurrentKey("No.");
        Customer.Setfilter("No.", '<>%1', '');
        Customer.SetFilter("Country/Region Code", '<>%1', 'DE');
        //Customer.Setrange("No.", 'C117018');
        if Customer.FindFirst() then begin
            repeat
                CustomerLedgerEntries.SetRange("Customer No.", Customer."No.");
                CustomerLedgerEntries.SetRange("Due Date", StartDate, EndDate);
                CustomerLedgerEntries.SetRange(Open, true);
                if CustomerLedgerEntries.FindFirst() then begin
                    Customer.CalcFields("Balance (LCY)");
                    if Customer."Balance (LCY)" <> 0 then begin
                        if Date2DMY(WorkDate, 1) = 1 then begin
                            SendEmail(Customer);
                        end;
                        if Date2DMY(WorkDate, 1) = 8 then begin
                            SendEmail2(Customer);
                        end;
                        if Date2DMY(WorkDate, 1) = 15 then begin
                            SendEmail3(Customer);
                        end;
                    end;
                end;
            until Customer.Next = 0;
        end;
    end;


    procedure SendEmail(var Customer: Record Customer)
    var
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;

        TxtDefaultCCMailList: List of [Text];
        TxtDefaultBCMailList: List of [Text];
        TxtRecipientsMailList: List of [Text];
        AttachmentTempBlob: Codeunit "Temp Blob";
        AttachmentIntStream: InStream;
        AttachmentOutStream: OutStream;
        SalesNReceivablesSetup: Record "Sales & Receivables Setup";
        Body: Label 'Dear Customer,<br><br>Please find your statement of account attached to this email. Your attention is drawn in particular to those red items which are due for payment immediately. If you have any queries with regards to items on the statement, please contact accounts@ericoglobal.com.<br><br> Otherwise, please pay the required funds into our bank account with immediate effect. We have a policy of automatically informing our credit insurers, Euler Hermes, of any debts which remain due 21 days after their original due date so it is in our mutual interests to ensure that all debts are paid up to date';
    begin
        Clear(CustomerStatements);
        Clear(AttachmentOutStream);
        Clear(AttachmentIntStream);
        //Customer.SetFilter("No.", Customer."No.");
        //Customer.FindFirst();
        CustomerStatements.SetTableView(Customer);

        TmpRecipients := DelChr(Customer."Customer Statement Email", '<>', ';');
        TmpRecipients := TmpRecipients + ';';
        while StrPos(TmpRecipients, ';') > 1 do begin
            TmpRecipient := Delchr(CopyStr(TmpRecipients, 1, StrPos(TmpRecipients, ';') - 1), '<>', ';');
            TmpRecipients := CopyStr(TmpRecipients, StrPos(TmpRecipients, ';') + 1);
            TxtRecipientsMailList.Add(TmpRecipient);
        end;

        //TxtDefaultBCMailList.Add(Vendor.BCC);

        //CountSubStrings(Vendor.BCC, ',');
        //TxtDefaultCCMailList.Add(Vendor.CC);



        EmailMessage.Create(
            TxtRecipientsMailList,
            'Customer Statement',
            SalesNReceivablesSetup.GetDay1Message(),
            true,
            TxtDefaultCCMailList,
            TxtDefaultBCMailList
        );

        AttachmentTempBlob.CreateOutStream(AttachmentOutStream);

        CustomerStatements.SaveAs(
            '<?xml version="1.0" standalone="yes"?><ReportParameters name="Statement" id="116"><Options><Field name="StartDate">' + format(txtStartDate) + '</Field><Field name="EndDate">' + format(txtEndDate) + '</Field><Field name="PrintEntriesDue">false</Field><Field name="PrintAllHavingEntry">false</Field><Field name="PrintAllHavingBal">true</Field><Field name="PrintReversedEntries">false</Field><Field name="PrintUnappliedEntries">false</Field><Field name="IncludeAgingBand">false</Field><Field name="PeriodLength">1M+CM</Field><Field name="DateChoice">0</Field><Field name="LogInteraction">true</Field><Field name="SupportedOutputMethod">3</Field><Field name="ChosenOutputMethod">3</Field><Field name="PrintIfEmailIsMissing">false</Field></Options><DataItems><DataItem name="Customer">VERSION(1) SORTING(Field1) WHERE(Field1=1(' + Customer."No." + '))</DataItem><DataItem name="Integer">VERSION(1) SORTING(Field1)</DataItem><DataItem name="CurrencyLoop">VERSION(1) SORTING(Field1)</DataItem><DataItem name="CustLedgEntryHdr">VERSION(1) SORTING(Field1)</DataItem><DataItem name="Detailed Cust. Ledg. Entry">VERSION(1) SORTING(Field9,Field4,Field3,Field10)</DataItem><DataItem name="CustLedgEntryFooter">VERSION(1) SORTING(Field1)</DataItem><DataItem name="CustLedgEntry2">VERSION(1) SORTING(Field3,Field36,Field43,Field37,Field11)</DataItem><DataItem name="AgingBandLoop">VERSION(1) SORTING(Field1)</DataItem></DataItems></ReportParameters>',
            ReportFormat::Pdf,
            AttachmentOutStream
        );

        AttachmentTempBlob.CreateInStream(AttachmentIntStream);
        AttachmentName := 'CustomerStatement' + format(WorkDate, 0, '<Year4>') + format(WorkDate, 0, '<Month,2>') + Customer."No." + '.pdf';

        EmailMessage.AddAttachment(
            AttachmentName,
            'PDF',
            AttachmentIntStream
        );

        if MyTryMethod(AttachmentIntStream) then
            Email.Send(EmailMessage, Enum::"Email Scenario"::Default);
    end;

    [TryFunction]
    local procedure MyTryMethod(var AttachmentIntStream: InStream)
    var
        EmailMessage: Codeunit "Email Message";
    begin
        EmailMessage.AddAttachment(
             AttachmentName,
             'PDF',
             AttachmentIntStream
         );
    end;

    procedure SendEmail2(var Customer: Record Customer)
    var
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;

        TxtDefaultCCMailList: List of [Text];
        TxtDefaultBCMailList: List of [Text];
        TxtRecipientsMailList: List of [Text];
        AttachmentTempBlob: Codeunit "Temp Blob";
        AttachmentIntStream: InStream;
        AttachmentOutStream: OutStream;
        SalesNReceivablesSetup: Record "Sales & Receivables Setup";
        Body: Label 'Dear Customer,<p><p>Last week, we sent a copy of your statement. We hope that, by now, any queries that you raised have been satisfactorily resolved and that you can now pay your account up to date.<p><p>If there are still problems to resolve, please let us know with immediate effect by contacting accounts@ericoglobal.com.';
    begin
        Clear(CustomerStatements);
        Clear(AttachmentOutStream);
        Clear(AttachmentIntStream);
        //Customer.SetFilter("No.", Customer."No.");
        //Customer.FindFirst();
        CustomerStatements.SetTableView(Customer);

        TmpRecipients := DelChr(Customer."Customer Statement Email", '<>', ';');
        TmpRecipients := TmpRecipients + ';';
        while StrPos(TmpRecipients, ';') > 1 do begin
            TmpRecipient := Delchr(CopyStr(TmpRecipients, 1, StrPos(TmpRecipients, ';') - 1), '<>', ';');
            TmpRecipients := CopyStr(TmpRecipients, StrPos(TmpRecipients, ';') + 1);
            TxtRecipientsMailList.Add(TmpRecipient);
        end;

        //TxtDefaultBCMailList.Add(Vendor.BCC);

        //CountSubStrings(Vendor.BCC, ',');
        //TxtDefaultCCMailList.Add(Vendor.CC);

        EmailMessage.Create(
            TxtRecipientsMailList,
            'Customer Statement',
            SalesNReceivablesSetup.GetDay2Message(),
            true,
            TxtDefaultCCMailList,
            TxtDefaultBCMailList
        );

        AttachmentTempBlob.CreateOutStream(AttachmentOutStream);

        CustomerStatements.SaveAs(
            '<?xml version="1.0" standalone="yes"?><ReportParameters name="Statement" id="116"><Options><Field name="StartDate">' + format(txtStartDate) + '</Field><Field name="EndDate">' + format(txtEndDate) + '</Field><Field name="PrintEntriesDue">false</Field><Field name="PrintAllHavingEntry">false</Field><Field name="PrintAllHavingBal">true</Field><Field name="PrintReversedEntries">false</Field><Field name="PrintUnappliedEntries">false</Field><Field name="IncludeAgingBand">false</Field><Field name="PeriodLength">1M+CM</Field><Field name="DateChoice">0</Field><Field name="LogInteraction">true</Field><Field name="SupportedOutputMethod">3</Field><Field name="ChosenOutputMethod">3</Field><Field name="PrintIfEmailIsMissing">false</Field></Options><DataItems><DataItem name="Customer">VERSION(1) SORTING(Field1) WHERE(Field1=1(' + Customer."No." + '))</DataItem><DataItem name="Integer">VERSION(1) SORTING(Field1)</DataItem><DataItem name="CurrencyLoop">VERSION(1) SORTING(Field1)</DataItem><DataItem name="CustLedgEntryHdr">VERSION(1) SORTING(Field1)</DataItem><DataItem name="Detailed Cust. Ledg. Entry">VERSION(1) SORTING(Field9,Field4,Field3,Field10)</DataItem><DataItem name="CustLedgEntryFooter">VERSION(1) SORTING(Field1)</DataItem><DataItem name="CustLedgEntry2">VERSION(1) SORTING(Field3,Field36,Field43,Field37,Field11)</DataItem><DataItem name="AgingBandLoop">VERSION(1) SORTING(Field1)</DataItem></DataItems></ReportParameters>',
            ReportFormat::Pdf,
            AttachmentOutStream
        );

        AttachmentTempBlob.CreateInStream(AttachmentIntStream);
        AttachmentName := 'CustomerStatement' + format(WorkDate, 0, '<Year4>') + format(WorkDate, 0, '<Month,2>') + Customer."No." + '.pdf';

        EmailMessage.AddAttachment(
            AttachmentName,
            'PDF',
            AttachmentIntStream
        );

        Email.Send(EmailMessage, Enum::"Email Scenario"::Default);

    end;

    procedure SendEmail3(var Customer: Record Customer)
    var
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;

        TxtDefaultCCMailList: List of [Text];
        TxtDefaultBCMailList: List of [Text];
        TxtRecipientsMailList: List of [Text];
        AttachmentTempBlob: Codeunit "Temp Blob";
        AttachmentIntStream: InStream;
        AttachmentOutStream: OutStream;
        SalesNReceivablesSetup: Record "Sales & Receivables Setup";
        Body: Label 'Dear customer, <p><p>Last week, we contacted you to resolve any matters which may be holding up payments on your account. If they have been resolved and you have paid your account up to date, we appreciate it. <p><p>If matters have not been resolved, and remain unresolved a week from today, we will have no option but to place your account on credit hold and to take steps to legally recover the debt if we deem that to be necessary. <p><p>Please help us to avoid this possibility by either paying any sums due or by getting in touch with us immediately at accounts@ericoglobal.com. The process mentioned here will be an automatic process, no further reminders will be sent out.';
    begin
        Clear(CustomerStatements);
        Clear(AttachmentOutStream);
        Clear(AttachmentIntStream);
        //Customer.SetFilter("No.", Customer."No.");
        //Customer.FindFirst();
        CustomerStatements.SetTableView(Customer);

        TmpRecipients := DelChr(Customer."Customer Statement Email", '<>', ';');
        TmpRecipients := TmpRecipients + ';';
        while StrPos(TmpRecipients, ';') > 1 do begin
            TmpRecipient := Delchr(CopyStr(TmpRecipients, 1, StrPos(TmpRecipients, ';') - 1), '<>', ';');
            TmpRecipients := CopyStr(TmpRecipients, StrPos(TmpRecipients, ';') + 1);
            TxtRecipientsMailList.Add(TmpRecipient);
        end;


        //TxtDefaultBCMailList.Add(Vendor.BCC);

        //CountSubStrings(Vendor.BCC, ',');
        //TxtDefaultCCMailList.Add(Vendor.CC);

        EmailMessage.Create(
            TxtRecipientsMailList,
            'Customer Statement',
            SalesNReceivablesSetup.GetDay3Message(),
            true,
            TxtDefaultCCMailList,
            TxtDefaultBCMailList
        );

        AttachmentTempBlob.CreateOutStream(AttachmentOutStream);

        CustomerStatements.SaveAs(
            '<?xml version="1.0" standalone="yes"?><ReportParameters name="Statement" id="116"><Options><Field name="StartDate">' + format(txtStartDate) + '</Field><Field name="EndDate">' + format(txtEndDate) + '</Field><Field name="PrintEntriesDue">false</Field><Field name="PrintAllHavingEntry">false</Field><Field name="PrintAllHavingBal">true</Field><Field name="PrintReversedEntries">false</Field><Field name="PrintUnappliedEntries">false</Field><Field name="IncludeAgingBand">false</Field><Field name="PeriodLength">1M+CM</Field><Field name="DateChoice">0</Field><Field name="LogInteraction">true</Field><Field name="SupportedOutputMethod">3</Field><Field name="ChosenOutputMethod">3</Field><Field name="PrintIfEmailIsMissing">false</Field></Options><DataItems><DataItem name="Customer">VERSION(1) SORTING(Field1) WHERE(Field1=1(' + Customer."No." + '))</DataItem><DataItem name="Integer">VERSION(1) SORTING(Field1)</DataItem><DataItem name="CurrencyLoop">VERSION(1) SORTING(Field1)</DataItem><DataItem name="CustLedgEntryHdr">VERSION(1) SORTING(Field1)</DataItem><DataItem name="Detailed Cust. Ledg. Entry">VERSION(1) SORTING(Field9,Field4,Field3,Field10)</DataItem><DataItem name="CustLedgEntryFooter">VERSION(1) SORTING(Field1)</DataItem><DataItem name="CustLedgEntry2">VERSION(1) SORTING(Field3,Field36,Field43,Field37,Field11)</DataItem><DataItem name="AgingBandLoop">VERSION(1) SORTING(Field1)</DataItem></DataItems></ReportParameters>',
            ReportFormat::Pdf,
            AttachmentOutStream
        );

        AttachmentTempBlob.CreateInStream(AttachmentIntStream);
        AttachmentName := 'CustomerStatement' + format(WorkDate, 0, '<Year4>') + format(WorkDate, 0, '<Month,2>') + Customer."No." + '.pdf';

        EmailMessage.AddAttachment(
            AttachmentName,
            'PDF',
            AttachmentIntStream
        );

        Email.Send(EmailMessage, Enum::"Email Scenario"::Default);

    end;

    /*procedure SendEmailThruSMTP(var GenJournalLine: Record "Gen. Journal Line")
    var
        SmtpMailSetup: Record "SMTP Mail Setup";
        Mail: Codeunit "SMTP Mail";
        Recipients: List of [Text];
        Subject: Text;
        Body: Text[1000];
        Sender: Text;
        SalesPostedTitle: Label 'The Sales Document %2 of Customer %1 has been posted.';
        SalesPostedMsg: Label 'Dear Manager<br><br>The Sales Document <font color="red"><strong>%2</strong></font> of Customer <strong>%1</strong> has been posted.<br> The total amount is <strong>%3</strong>. <br>The Posted Invoice Number is <strong>%4</strong>. <br> User ID <strong>%5</strong>';
        TxtDefaultCCMailList: List of [Text];
        TxtDefaultBCMailList: List of [Text];
        TxtRecipientsMailList: List of [Text];
        AttachmentTempBlob: Codeunit "Temp Blob";
        AttachmentIntStream: InStream;
        AttachmentOutStream: OutStream;
        BankIntegrationSetup: Record RAC_BankIntegration;
    begin
        Mail.Initialize();
        Clear(PaymentDetails);
        Vendor.SetFilter("No.", GenJournalLine."Bill-to/Pay-to No.");
        Vendor.FindFirst();
        //PaymentDetails.SetTableView(Vendor);


        setParameterInPaymentReport(GenJournalLine);


        if not SmtpMailSetup.Get() then
            exit;

        BankIntegrationSetup.Get();

        Clear(Recipients);
        Recipients.Add(Vendor."Email 2");
        //PaymentDetails.SetTableView(Vendor);

        //Mail.Initialize();

        Sender := BankIntegrationSetup.RAC_FromName;
        Subject := BankIntegrationSetup.RAC_Subject;
        Body := BankIntegrationSetup.RAC_Body;

        /*Mail.AddBCC(TxtDefaultBCMailList);
        Mail.AddCC(TxtDefaultCCMailList);
        Mail.AddRecipients(Recipients);
        Mail.AddSubject(Subject);
        Mail.AddBody(Body);
        Mail.AddFrom(Sender, SmtpMailSetup."User ID");
        //Mail.GetO365SmtpServer();
        //Mail.GetDefaultSmtpPort();
        //Mail.ApplyOffice365Smtp(SmtpMailSetup);*/

    /*Mail.CreateMessage(Sender, SmtpMailSetup."User ID", Recipients, Subject, Body, true);
    AttachmentTempBlob.CreateOutStream(AttachmentOutStream);
    PaymentDetails.SaveAs(
       '',
       ReportFormat::Pdf,
       AttachmentOutStream
   );
    AttachmentTempBlob.CreateInStream(AttachmentIntStream);
    Mail.AddAttachmentStream(AttachmentIntStream, 'EastWestBankPaymentDetails.pdf');


    if not Mail.Send() then
        Message(Mail.GetLastSendMailErrorText());
end;*/

    local procedure CountSubStrings(String: Text[250]; Character: Text[1]) CharCount: Integer
    var
        myInt: Integer;
        CharPos: Integer;
        CountingString: Text;
    begin
        CharCount := 0; // local Var
        CharPos := 0; // local Var
        CountingString := ''; // local Var

        CountingString := TrimString(String, Character); //Call to 2nd function below

        CharPos := STRPOS(String, Character);

        REPEAT
            CountingString := COPYSTR(CountingString, CharPos + 1);
            CharCount := CharCount + 1;
            CharPos := STRPOS(CountingString, Character);
        UNTIL CharPos = 0;

        EXIT(CharCount + 1);
    end;

    local procedure TrimString(String: Text[250]; Character: Text[1]) TrimmedString: Text[250]
    var
        myInt: Integer;
    begin
        TrimmedString := String;
        IF (STRPOS(String, Character) = 1) THEN
            TrimmedString := COPYSTR(String, 2);
        IF (COPYSTR(String, STRLEN(String)) = Character) THEN
            TrimmedString := COPYSTR(TrimmedString, 1, STRLEN(TrimmedString) - 1);
    end;

    /*[EventSubscriber(ObjectType::Codeunit, Codeunit::"SMTP Mail", 'OnBeforeSend', '', false, false)]
    local procedure MyProcedure(var SMTPMailSetup: Record "SMTP Mail Setup")
    var
        smtpsetup: Record "SMTP Mail Setup";
    begin
        smtpsetup.Get();
        SMTPMailSetup.Copy(smtpsetup);
    end;*/

    procedure setParameterInPaymentReport(var GenJnlLine: Record "Gen. Journal Line")
    var

    begin
        Genjnl.Copy(GenJnlLine);
    end;

    procedure getParameterInPaymentReport(): Record "Gen. Journal Line"
    var
    begin
        Exit(Genjnl);
    end;

    var
        Vendor: Record Vendor;
        CustomerStatements: Report EricoStatement;
        Customer: Record Customer;
        Genjnl: Record "Gen. Journal Line";
        IntStr: Text;
        StartDate: Date;
        EndDate: Date;
        txtEndDate: Text;
        txtStartDate: Text;
        AttachmentName: Text;
        TmpRecipients: Text;
        TmpRecipient: Text;

}