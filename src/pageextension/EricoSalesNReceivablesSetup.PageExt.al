pageextension 70101 EricoSalesNReceivablesSetup extends "Sales & Receivables Setup"
{
    layout
    {
        addafter("Check Multiple Posting Groups")
        {
            field("Customer Blocking Email"; Rec."Customer Blocking Email")
            {
                ApplicationArea = All;
            }
        }
        addafter(Prices)
        {
            group(CustomerEmailSetup)
            {
                Caption = 'Customer Statement Day 1 Message';
                field("Email Editor"; EmailBody)
                {
                    Caption = 'Message';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the content of the email.';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                    //Editable = not EmailScheduled;

                    trigger OnValidate()
                    begin
                        rec.SetDay1Message(EmailBody);
                    end;
                }




            }
            group(CustomerEmailSetup2)
            {
                Caption = 'Customer Statement Day 2 Message';
                field("Email Editor2"; EmailBody2)
                {
                    Caption = 'Message';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the content of the email.';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                    //Editable = not EmailScheduled;

                    trigger OnValidate()
                    begin
                        rec.SetDay2Message(EmailBody2);
                    end;
                }
            }
            group(CustomerEmailSetup3)
            {
                Caption = 'Customer Statement Day 3 Message';
                field("Email Editor3"; EmailBody3)
                {
                    Caption = 'Message';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the content of the email.';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                    //Editable = not EmailScheduled;

                    trigger OnValidate()
                    begin
                        rec.SetDay3Message(EmailBody3);
                    end;
                }

            }

        }
    }



    actions
    {
        // Add changes to page actions here
    }

    trigger OnAfterGetRecord()
    var

    begin
        EmailBody := Rec.GetDay1Message();
        EmailBody2 := Rec.GetDay2Message();
        EmailBody3 := Rec.GetDay3Message();
    end;

    var
        EmailBody: Text;
        EmailBody2: Text;
        EmailBody3: Text;


}