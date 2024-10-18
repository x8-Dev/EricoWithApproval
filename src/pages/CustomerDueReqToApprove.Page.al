page 70100 CustomerDueReqToApprove
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Customer Due - Request to Approve';
    SourceTable = CustomerDueReqstToApprove;
    DeleteAllowed = false;
    ModifyAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    var
                        SalesOrder: Record "Sales Header";
                        SalesOrderCard: Page "Sales Order";
                    begin
                        SalesOrder.SetRange("No.", rec."Document No.");
                        SalesOrderCard.SetTableView(SalesOrder);
                        SalesOrderCard.Run();
                    end;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Sender ID"; Rec."Sender ID")
                {
                    ApplicationArea = All;
                }
                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(Approved)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                begin
                    SalesHeader.SetRange("No.", Rec."Document No.");
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                    if SalesHeader.FindFirst() then begin
                        SalesHeader."Due Exceed Status" := SalesHeader."Due Exceed Status"::Approved;
                        rec."Approved By" := UserId;
                        rec."Date Approved" := Today;
                        rec.Status := rec.Status::Approved;
                        rec.Modify();
                        SalesHeader.Modify();
                        SendEmail();
                        CurrPage.Update();
                    end;
                end;
            }
            action(Reject)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                begin
                    SalesHeader.SetRange("No.", Rec."Document No.");
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                    if SalesHeader.FindFirst() then begin
                        SalesHeader."Due Exceed Status" := SalesHeader."Due Exceed Status"::Rejected;
                        SalesHeader.Modify();
                        rec.Status := rec.Status::Rejected;
                        rec."Approved By" := UserId;
                        rec.Modify();
                        SendEmailRejected();
                    end;
                end;
            }


        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        myInt: Integer;
    begin
        Rec.SetRange(Status, Rec.Status::New);
        EXIT(Rec.FInd(Which) AND CheckIfApprover());
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        NewStepCount: Integer;
    BEGIN
        REPEAT

            NewStepCount := Rec.Next(Steps);
        UNTIL (NewStepCount = 0) OR CheckIfApproverAndStatus();

        EXIT(NewStepCount);
    END;

    local procedure CheckIfApprover(): Boolean
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.get(UserId) then begin
            if (UserSetup."Overdue Approver" = true) then
                exit(true);
        end;
    end;

    local procedure CheckIfApproverAndStatus(): Boolean
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.get(UserId) then begin
            if (UserSetup."Overdue Approver" = true) and (rec.Status = rec.Status::New) then
                exit(true);
        end;
    end;

    procedure SendEmail()
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
        UserSetup: Record "User Setup";
        Body: Label 'Hi,<br><br>Sales Order No. %1 has been approved by Approver %2';
        EnvironmentInfo: Codeunit "Environment Information";
        CompanyInfo: Record "Company Information";
    begin
        UserSetup.SetRange("User ID", rec."Sender ID");
        if UserSetup.FindFirst() then begin
            repeat
                TmpRecipients := DelChr(UserSetup."E-Mail", '<>', ';');
                TmpRecipients := TmpRecipients + ';';
                while StrPos(TmpRecipients, ';') > 1 do begin
                    TmpRecipient := Delchr(CopyStr(TmpRecipients, 1, StrPos(TmpRecipients, ';') - 1), '<>', ';');
                    TmpRecipients := CopyStr(TmpRecipients, StrPos(TmpRecipients, ';') + 1);
                    TxtRecipientsMailList.Add(TmpRecipient);
                end;
            until UserSetup.next = 0;
        end;

        //TxtDefaultBCMailList.Add(Vendor.BCC);

        //CountSubStrings(Vendor.BCC, ',');
        //TxtDefaultCCMailList.Add(Vendor.CC);

        CompanyInfo.Get();

        EmailMessage.Create(
            TxtRecipientsMailList,
            'Approved Sales Order',
            STRSUBSTNO(Body, rec."Document No.", rec."Approved By"),
            true,
            TxtDefaultCCMailList,
            TxtDefaultBCMailList
        );

        Email.Send(EmailMessage, Enum::"Email Scenario"::Default);
    end;

    procedure SendEmailRejected()
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
        UserSetup: Record "User Setup";
        Body: Label 'Hi,<br><br>Sales Order No. %1 has been rejected by Approver %2';
        EnvironmentInfo: Codeunit "Environment Information";
        CompanyInfo: Record "Company Information";
    begin
        UserSetup.SetRange("User ID", rec."Sender ID");
        if UserSetup.FindFirst() then begin
            repeat
                TmpRecipients := DelChr(UserSetup."E-Mail", '<>', ';');
                TmpRecipients := TmpRecipients + ';';
                while StrPos(TmpRecipients, ';') > 1 do begin
                    TmpRecipient := Delchr(CopyStr(TmpRecipients, 1, StrPos(TmpRecipients, ';') - 1), '<>', ';');
                    TmpRecipients := CopyStr(TmpRecipients, StrPos(TmpRecipients, ';') + 1);
                    TxtRecipientsMailList.Add(TmpRecipient);
                end;
            until UserSetup.next = 0;
        end;

        //TxtDefaultBCMailList.Add(Vendor.BCC);

        //CountSubStrings(Vendor.BCC, ',');
        //TxtDefaultCCMailList.Add(Vendor.CC);

        CompanyInfo.Get();

        EmailMessage.Create(
            TxtRecipientsMailList,
            'Rejected Sales Order',
            STRSUBSTNO(Body, rec."Document No.", UserId),
            true,
            TxtDefaultCCMailList,
            TxtDefaultBCMailList
        );

        Email.Send(EmailMessage, Enum::"Email Scenario"::Default);
    end;

    var
        TmpRecipients: Text;
        TmpRecipient: Text;

}
