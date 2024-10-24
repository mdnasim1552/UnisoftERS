<telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" Modal="true">
</telerik:RadAjaxLoadingPanel>

<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="procedurefooter.ascx.vb" Inherits="UnisoftERS.procedurefooter" %>

<style>

    .manButton{
        border-radius: 10px !important;
        font-weight:bold !important;
        color: seagreen !important;
    }
    .procedureButton{
        border-radius: 10px !important;
    }
    html .RadButton.RadButton_Metro.rbLinkButton.rbRounded.rbHovered,
    html .RadButton_Metro.rbLinkButton.rbRounded:hover {
        background-color: #25a0de;
    }


</style>


<div id="cmdOtherData" runat="server" style="padding-top: 07px; padding-bottom:10px;">
    <div style="width: 30%; float:left">
        <telerik:RadButton ID="cmdMainScreen" runat="server" Text="Main screen" Skin="Metro" CssClass="manButton" ButtonType="SkinnedButton" OnClientClicking="onReportButtonClicking" Icon-PrimaryIconUrl="~/Images/icons/GoPrevious5.png" OnClick="cmdMainScreen_Click" /> &nbsp;
        <telerik:RadButton ID="cmdShowReport" runat="server" Text="Show/Hide report" Skin="Metro" CssClass="manButton" ButtonType="SkinnedButton" AutoPostBack="true" OnClick="cmdShowReport_Click" />
    </div>
        <div style="width: 70%; display: flex; flex-direction: row; align-items: center; justify-content: right;">
        <telerik:RadButton ID="cmdPreProcedure" runat="server" CssClass="procedureButton" Text="Pre Procedure" Skin="Metro" ButtonType="SkinnedButton" OnClientClicking="onReportButtonClicking"/> &nbsp;
        <telerik:RadButton ID="cmdProcedure" runat="server" CssClass="procedureButton" Text="Procedure" Skin="Metro" ButtonType="SkinnedButton" OnClientClicking="onReportButtonClicking"/> &nbsp;
        <telerik:RadButton ID="cmdPostProcedure" runat="server" CssClass="procedureButton" Text="Post Procedure" Skin="Metro" ButtonType="SkinnedButton" OnClientClicking="onReportPostProcedureButtonClicking" /> &nbsp;
        <telerik:RadButton ID="cmdPrint" runat="server" CssClass="procedureButton" Text="Review & Print" Skin="Metro" ButtonType="SkinnedButton" OnClientClicking="onReportButtonClicking"/> &nbsp;
        <telerik:RadButton ID="cmdCreateTab" runat="server" CssClass="procedureButton" Text="Create tab" Skin="Metro" ButtonType="SkinnedButton" Visible="false"/>
    </div>
</div>


<telerik:RadNotification ID="PrintRadNotification" runat="server" Animation="None"
    Title="Please correct the following"
    LoadContentOn="PageLoad" TitleIcon="warning" Position="Center" OnClientHiding="OnClientHiding"
    AutoCloseDelay="0" Skin="Metro" Width="500px">
    <ContentTemplate>
        <div id="valDiv" runat="server" class="aspxValidationSummary page-validation"></div>
        <div style="height: 20px; margin-left: 10px; margin-bottom: 5px; float: right">
            <telerik:RadButton ID="CloseButtn" runat="server" AutoPostBack="false" Skin="Metro" Text="Close" OnClientClicked="CloseWindow" Visible="false">
                <ToggleStates>
                    <telerik:RadButtonToggleState PrimaryIconUrl="~/images/icons/Cancel.png" Text="Close"></telerik:RadButtonToggleState>
                    <telerik:RadButtonToggleState PrimaryIconUrl="~/images/icons/ajax-loader.gif" Text="Closing..."></telerik:RadButtonToggleState>
                </ToggleStates>
            </telerik:RadButton>
            <%--<telerik:RadButton ID="CloseButtn1" runat="server" Text="Close" Skin="Web20" AutoPostBack="false" OnClientClicked="CloseVerifier" ButtonType="SkinnedButton" Icon-PrimaryIconCssClass="telerikCancelButton"/>--%>
        </div>
    </ContentTemplate>
</telerik:RadNotification>

<telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            <%--$('#<%=cmdPostProcedure.ClientID%>').on('click', function () {
                var webMethodUrl = document.URL.slice(0, docURL.indexOf("/Products/")) + "/Products/Reports/WebMethods.aspx/UpdateDiagnoses";
                $.ajax({
                    type: "POST",
                    url: webMethodUrl,
                    dataType: "json",
                    data: JSON.stringify({ procedureId: parseInt(<%=Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>) }),
                    contentType: "application/json; charset=utf-8",
                    success: function (data) {
                        refreshSummary();
                    }
                });                
            });--%>
        });

        function OnClientHiding(sender, eventArgs) {
            //window.location.replace(sender.get_value());
        }

        function onReportButtonClicking(sender, args) {
            newProcedureInitiated = false;
        }
        function onReportPostProcedureButtonClicking(sender, args) {
            newProcedureInitiated = false;
            SetTreeNode(0);
        }
        function CloseVerifier(sender, eventArgs) {
            var clseButton = $find("<%=CloseButtn.ClientID%>");
            var prtRadNotification = $find("<%=PrintRadNotification.ClientID%>");
            var pageURL = $find("<%=PrintRadNotification.ClientID%>").get_value();
            //var primaryIconElement = clseButton.get_primaryIconElement();
            //$telerik.$(primaryIconElement).css("background-image", "../Images/icons/edit.png");
            if (pageURL.indexOf("PapillaryAnatomy") >= 0) {
                openPapillaryAnatomyWindow();
                clseButton.set_selectedToggleStateIndex(0);
                prtRadNotification._close(true);
            } else {
                window.location.replace(prtRadNotification.get_value());
            }
        }

        function enableDisableProcedureButton(enable) {
            var radButton = $find("<%=cmdProcedure.ClientID%>");
            radButton.set_enabled(!enable);
        }  

        function alertCallBackFn(arg) {
            radalert("<strong>radalert</strong> returned the following result: <h3 style='color: #ff0000;'>" + arg + "</h3>", null, null, "Result");
        }

        function closeDialogDeleteProc() {
            $find("<%=DeleteProcRadWindow.ClientID%>").close();
        }

        function DisplayMessage(sender, args) {
            var oWnd = $find("<%=DeleteProcRadWindow.ClientID%>");
            $('#<%= lblDeleteMessage.ClientID%>').html("What do you want to happen?");//("Report INCOMPLETE <br />-------------------------<br /> Clicking DELETE will delete this report. <br />Cancel to return to the home page.<br /><br />");
            oWnd.show();
            return false;
        }
    </script>
</telerik:RadCodeBlock>

<telerik:RadWindowManager ID="PatientProcedureRadWindowManager" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move, Resize" Skin="Metro" EnableShadow="true" Modal="true">
    <Windows>
        <telerik:RadWindow ID="DeleteProcRadWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" Width="700px" Height="200px" VisibleStatusbar="false" VisibleOnPageLoad="false" Title="Report Incomplete" BackColor="#ffffcc">
            <ContentTemplate>
                <table width="100%">
                    <tr>
                        <td style="vertical-align: top; padding-left: 20px; padding-top: 40px">
                            <img id="Img1" runat="server" src="~/Images/info-32x32.png" />
                        </td>
                        <td style="text-align: center; padding: 20px;">
                            <asp:Label ID="lblDeleteMessage" runat="server" Font-Size="Large" />
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td style="padding: 10px; text-align: center; padding-top: 30px !important;">
                            <telerik:RadButton ID="DeleteProcRadButton" runat="server" Text="Delete this report" Skin="Windows7" ForeColor="#cc3300" ButtonType="SkinnedButton" Font-Size="Large" Style="margin-right: 20px;" />
                            <telerik:RadButton ID="KeepProcRadButton" runat="server" Text="Keep this report" Skin="Windows7" ButtonType="SkinnedButton" Font-Size="Large" Style="margin-right: 20px;" OnClientClicked="closeDialogDeleteProc" />
                            <telerik:RadButton ID="CancelDeleteRadButton" runat="server" Text="Cancel" Skin="Windows7" ButtonType="SkinnedButton" AutoPostBack="false" OnClientClicked="closeDialogDeleteProc" Font-Size="Large" />
                        </td>
                    </tr>
                </table>
            </ContentTemplate>
        </telerik:RadWindow>
    </Windows>
</telerik:RadWindowManager>
