<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Notes" Codebehind="Notes.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />

     <style type="text/css">
        .SiteDetailsForm {
            font-size: 12px;
            font-family: "Segoe UI",Arial,Helvetica,sans-serif;
            color: black;
        }

            .SiteDetailsForm td {
                padding-bottom: 10px;
            }
        .rbl label
        {
            margin-right: 15px;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            var noteChanged = false;
            $("#EraseButton").click(function () {

                if (!confirm("Are you sure you want to erase these notes?")) {
                    return false;
                }
                else {
                    $("#NotesTextBox").val("");
                }
            });
            $("#NotesTextBox").on('change', function () {
                noteChanged = true;
                if (($("#NotesTextBox").val()).trim() !== '') localStorage.setItem('valueChanged', 'true');
                else localStorage.setItem('valueChanged', 'false');
            });
            $(window).on('beforeunload', function () {
                if (noteChanged) SaveRecordByClick();
                setRehideSummary();
            });
        });

        function SaveRecordByClick() {
            var obj = {};
            obj.saveAndClose = true;
            obj.Notes = ($("#NotesTextBox").val()).trim();
            $.ajax({
                type: "POST",
                url: "Notes.aspx/SaveRecordByClick",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    //setRehideSummary();
                },
                error: function (x, y, z) {
                }
            });
        }

        function CloseWindow() {
            window.parent.CloseWindow();
        }

    </script>
</head>
<body>
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            function savePage() {
                $find('<%= RadAjaxManager1.ClientID %>').ajaxRequest();
            }            

        </script>
    </telerik:RadScriptBlock>  
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="NotesRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="NotesRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Additional notes</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">



                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">


                            <table id="NotesTable" class="rgview" cellpadding="0" cellspacing="0" style="width:780px">
                                <colgroup>
                                    <col><col><col>
                                </colgroup>
                                <thead>

                                </thead>
                                <tbody>

                                    <tr>
                                        <td width="600px" height="40px" class="" style="text-align: left;">
                                            <asp:Label ID="hintLabel" runat="server" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding:20px 10px 20px 10px;">
                                            <telerik:RadTextBox ID="NotesTextBox" runat="server" Width="758px" Height="200px" 
                                                TextMode="MultiLine" Resize="Both" MaxLength="5000">
                                            </telerik:RadTextBox>
                                        </td>
                                    </tr>

                                </tbody>
                            </table>

                        </div>
                    </div>
                </div>


            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px;">
                    <%--<telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                    <telerik:RadButton ID="EraseButton" runat="server" Text="Erase notes" Skin="Web20" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>--%>
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
