<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="PlannedExtent.ascx.vb" Inherits="UnisoftERS.PlannedExtent" %>
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;

        $(window).on('load', function () {
            var extentId = $find('<%=PlannedExtentRadComboBox.ClientID%>').get_selectedItem().get_value();
            if (extentId > 0)
                savePlannedExtent(extentId, '');
            //added by rony tfs-2830
            togglePlannedExtentChangedControls();
            togglePlannedExtent();
        });

        $(document).ready(function () {


        });
       <%-- function reloadControl() {
            __doPostBack('<%= UpdatePanel1.UniqueID %>', '');
        }--%>

        
        function planned_extent_changed(sender, args) {
            var extentId = args.get_item().get_value();            
            //reloadControl();            
            //added by rony tfs-2830
            var plannedExtentVal = args.get_item().get_attributes().getAttribute('data-planned-extent')
            $("#PlannedExtentComboBoxInput").val(plannedExtentVal);
            var str = $('.plannedLabel tr td:first-child').html();
            var search = "UpperExtentComboBox_Input";
            if (str.includes(search)) {
                resetUpperExtent();
            } else {
                resetLowerExtent();
            }           
            savePlannedExtent(extentId, '');
            togglePlannedExtent();
        }
        //added by rony tfs-2830
        function togglePlannedExtentChangedControls() {
            var plannedVal = $find('<%=PlannedExtentRadComboBox.ClientID%>').get_selectedItem().get_attributes().getAttribute('data-planned-extent');
            $("#PlannedExtentComboBoxInput").val(plannedVal);
        }
        function savePlannedExtent(extentId, otherText) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.extentId = parseInt(extentId);

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/savePlannedExtent",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    setRehideSummary();
                  
                },
                error: function (x, y, z) {
                    autoSaveSuccess = false;
                    //show a message
                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                    $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();
                }
            });
           
        }

        function togglePlannedExtent() {
            var plannedVal = $find('<%=PlannedExtentRadComboBox.ClientID%>');
            var text = $find('<%=PlannedExtentRadComboBox.ClientID%>').get_text().toLowerCase();
            var items = plannedVal.get_items();
            if (text !== '') {
                for (var i = 0; i < items.get_count(); i++) {
                    var item = items.getItem(i);
                    if (item.get_text() === '') {
                        item.set_visible(false);
                    }
                }
            }
        }
    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<%--<asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Always">
<ContentTemplate>--%>
<div class="control-content">
    <table>
        <tr>
            <td>
                <span>Planned extent:<img src="../../Images/NEDJAG/Ned.png" alt="NED Field" /></span></td>
            <td>
                <%--added by rony tfs-2830--%>
                <telerik:RadComboBox ID="PlannedExtentRadComboBox" runat="server" Skin="Metro" DataTextField="Description" DataValueField="UniqueId" OnClientSelectedIndexChanged="planned_extent_changed" AppendDataBoundItems="true" OnItemDataBound="PlannedExtentRadComboBox_ItemDataBound">
                    <Items>
                        
                    </Items>
                </telerik:RadComboBox>
                <%--Added by rony tfs-2830--%>
                <input type="hidden" id="PlannedExtentComboBoxInput"/>
            </td>
        </tr>
    </table>
</div>
<%--</ContentTemplate>
     <Triggers>
        <asp:AsyncPostBackTrigger ControlID="PlannedExtentRadComboBox" EventName="SelectedIndexChanged" />
    </Triggers>
</asp:UpdatePanel>--%>

