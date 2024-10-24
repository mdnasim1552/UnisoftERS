<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="PreviousSurgery.ascx.vb" Inherits="UnisoftERS.PreviousSurgery" %>
<script type="text/javascript">
    var AddNewItemRadTextBoxClientId = "<%= AddNewItemRadTextBox.ClientID %>";
    var AddNewItemRadWindowClientId = "<%= AddNewItemRadWindow.ClientID %>";

    function savePreviousHistory(ids) {
        var obj = {};
        obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
        obj.patientId = parseInt(getCookie('patientId'));
        obj.previousSurgeryId = ids;
        obj.previousSurgeryPeriod = 0;

        $.ajax({
            type: "POST",
            url: "PreProcedure.aspx/savePreviousSurgery",
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

                $find('<%=AddNewItemRadTextBox.ClientID%>').set_text(errorString);
                $find('<%=AddNewItemRadWindow.ClientID%>').show();
            }
        });
    }

    function comboLoad(sender) {
        if ('<%= Session("CanEditDropdowns") %>' == 'True') {
            var itemCount = sender.get_items().get_count();
            var item = sender.get_items().getItem(itemCount - 1),
            checkBoxElement = item.get_checkBoxElement(),
            itemParent = checkBoxElement.parentNode;
            itemParent.removeChild(checkBoxElement);
        } else return;
    }

    function onPSComboClose(sender) {
        var checkedItems = sender.get_checkedItems();
        var ids = [];
        var newItem = '';
        if (checkedItems.length > 0) {
            for (var i = 0; i < checkedItems.length; i++) {
                var currentVal = checkedItems[i]._properties._data.value;
                if (currentVal == -55) {
                    return;
                } else if (currentVal == -99) {
                    newItem = checkedItems[i]._properties._data.text;
                } else {
                    ids.push(currentVal);
                }

            }

            if (newItem != '') {
                var obj = {};
                obj.sectionName = 'Previous surgery';
                obj.newText = newItem;

                $.ajax({
                    type: "POST",
                    url: "PreProcedure.aspx/saveNewTextEntry",
                    data: JSON.stringify(obj),
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function (data) {
                        if (data.d > 0) {
                            ids.push(data.d);
                            ClearComboBox("<%= PreviousSurgeryComboBox.ClientID %>");
                            savePreviousHistory(ids.join(','));
                        }
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
            } else {
                savePreviousHistory(ids.join(','));
            }
        }
        else {
            savePreviousHistory(-1111);
        }
    }
</script>

<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<div class="control-sub-header">Previous Surgery/Procedures</div>
<div class="control-content">
    <telerik:RadComboBox ID="PreviousSurgeryComboBox" runat="server" Skin="Metro" Width="42%" OnClientLoad="comboLoad"
        Style="margin-right: 5px;" DataTextField="Description" DataValueField="UniqueId" CheckBoxes="True" OnClientDropDownClosed="onPSComboClose" />
</div>
<telerik:RadWindowManager ID="RadMan" runat="server" Modal="true" Animation="Fade" KeepInScreenBounds="true" Behaviors="Close" Skin="Metro" VisibleStatusbar="false" VisibleOnPageLoad="false">
    <Windows>
        <telerik:RadWindow ID="AddNewItemRadWindow" runat="server" ReloadOnShow="true" VisibleStatusbar="false" Title="Add new Item"
            KeepInScreenBounds="true" Width="400px" Height="150px" OnClientClose="AddNewItemWindowClientClose">
            <ContentTemplate>
                <table cellspacing="3" cellpadding="3" style="width: 100%">
                    <tr>
                        <td>
                            <br />
                            <div class="left">
                                <telerik:RadTextBox ID="AddNewItemRadTextBox" runat="Server" Width="250px" />
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div id="buttonsdiv" style="height: 10px; padding-top: 16px;">
                                <telerik:RadButton ID="AddNewItemSaveRadButton" runat="server" Text="Add" Skin="WebBlue" AutoPostBack="false" OnClientClicked="AddNewItem" ButtonType="SkinnedButton" />
                                &nbsp;&nbsp;
                                        <telerik:RadButton ID="AddNewItemCancelRadButton" runat="server" Text="Cancel" Skin="WebBlue" AutoPostBack="false" OnClientClicked="CancelAddNewItem" ButtonType="SkinnedButton" />
                            </div>
                        </td>
                    </tr>
                </table>
            </ContentTemplate>
        </telerik:RadWindow>
    </Windows>
</telerik:RadWindowManager>
