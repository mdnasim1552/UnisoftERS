<%@ Page Title="" Language="VB" MasterPageFile="~/Templates/Unisoft.master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Common_Rx" Codebehind="Rx.aspx.vb" %>
<%@ MasterType VirtualPath="~/Templates/Unisoft.master" %>

<asp:Content ID="RXHead" ContentPlaceHolderID="HeadContent" Runat="Server">
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
</asp:Content>
<asp:Content ID="RXBody" ContentPlaceHolderID="BodyContent" Runat="Server">
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
    <div id="cmdOtherData">
        <div class="otherDataHeading"><b>Patient Medication</b></div>

        <div style="margin: 5px 10px;">
            <div style="margin-top: 10px; margin-bottom: 20px;">
                <fieldset id="DocumentationFieldset" runat="server" class="otherDataFieldset">
                    <legend>Hint</legend>
                        You can edit the text in red. But only do so after the medication has been set via the boxes and buttons. 
                        If you edit the text then try and change the medication you will be advised that the original edits will be lost.
                </fieldset>
            </div>
        </div>








    <div class="rptSummaryText10" style="margin-left: 10px;">

        <div style="margin-left: 10px;" class="optionsHeadingNote">
            <b>Hint:</b><br /> You can edit the text in red. But only do so after the medication has been set via the boxes and buttons. 
              If you edit the text then try and change the medication you will be advised that the original edits will be lost.
        </div>

        <table id="table1" runat="server" cellspacing="0" cellpadding="0" border="0">
            <tr>
                <td style="width: 230px;"><asp:CheckBox ID="CheckBox1" runat="server" Text="Continue existing medication" /></td>
                <td></td>
            </tr>
            <tr>
                <td><asp:CheckBox ID="CheckBox2" runat="server" Text="Medication to be prescribed by GP" /></td>
                <td></td>
            </tr>
            <tr>
                <td><asp:CheckBox ID="CheckBox3" runat="server" Text="Medication to be prescribed by hospital" /></td>
                <td></td>
            </tr>
            <tr>
                <td><asp:CheckBox ID="CheckBox4" runat="server" Text="Suggest medication" /></td>
                <td></td>
            </tr>
            <tr>
                <td colspan="2" style="height: 7px;"></td>
            </tr>
            <tr>
                <td colspan="2">&nbsp;<telerik:RadTextBox ID="RadTextBox1" runat="server" Skin="Office2007" TextMode="MultiLine" Height="100" Width="400" /></td>
            </tr>
        </table>    
    </div>
    <div style="margin: 5px 15px;">
        <telerik:RadButton ID="cmdAccept" runat="server" Text="Accept" Skin="Web20" />
        <telerik:RadButton ID="cmdCancel" runat="server" Text="Cancel" Skin="Web20" OnClick="cancelRecord" />
    </div>
</div>
</asp:Content>

