<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="CoMorbidity.ascx.vb" Inherits="UnisoftERS.CoMorbidity" %>
<style type="text/css">
    .DataBoundTable td {
        width: 33.3%;
    }

    .gi-bleeds-button {
        margin-left: 5px;
    }

    .comorb-child {
        margin-left: 10px;
    }
    .margin-bot{
        margin-bottom: -25px;
    }
    .other-pad
    {
        margin-bottom: -28px;
    }
    .com-top
    {
        margin-top: 7px;
    }

</style>

<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;
        var isComorbidityChange = false;
        $(window).on('load', function () {
            var section = 'comorbidity';
            $('.' + section + '-other-entry-toggle input').each(function (idx, itm) {
                if ($(this).is(':checked')) {
                    $('.' + section + '-other-text-entry').show();
                }
                else {
                    $('.' + section + '-other-text-entry').hide();
                }
            });
        });

        $(document).ready(function () {
            $('.comorbidity-other-text-entry').hide();
            $('.comorbidity-additional-info').on('focusout', function () {
                var comorbId = $(this).attr('data-comorbid');
                var additionalInfoText = $(this).val();
                var checked = (additionalInfoText != '');

                saveComorbidity(comorbId, 0, checked, additionalInfoText);
            });
            $('.comorbidity-additional-info').each(function () {
                if ($(this).val().trim() !== '') {
                    $('.comorbidity-other-text-entry').show();
                    return false; 
                }
            });
            $('.comorb-parent input').on('change', function () {
                var childControl = $(this).closest('td').find('.comorb-child');
                if (childControl.length > 0) {
                    if ($(this).is(':checked')) {
                        $(childControl).show();
                    }
                    else {
                        $(childControl).hide();
                        //edited by siddik #TFS 3779
                        var comboBox = $find($(childControl).attr('id'));
                        comboBox.clearSelection();
                    }
                }

                //auto save
                var id = $(this).closest('td').find('.comorb-parent').attr('data-comorbid');
                var checked = $(this).is(':checked');


                saveComorbidity(id, 0, checked, '');

                //untick none
                if ($(this).closest('span').text().toLowerCase() != 'none') {

                    $(".comorbidity-none input").prop('checked', false);
                    var noneID = $(".comorbidity-none").attr('data-comorbid');
                    saveComorbidity(noneID, 0, false, '');
                }
                else {
                    if (checked) {//untick all
                        $(".comorb-parent input:checked").not('.comorbidity-none input').each(function (idx, itm) {
                            $(this).prop('checked', false);
                        });

                        //hide child controls 
                        $('.comorb-child').each(function (itm, idx) {
                            $(this).hide();
                            $(this).val('');
                            //edited by siddik #TFS 3779
                            var comboBox = $find($(this).attr('id'));
                            comboBox.clearSelection();
                        })

                        //hode other textbox
                        $('.comorbidity-other-text-entry').hide();
                    }
                }
            });

            $('.comorbidity-other-entry-toggle input').on('change', function () {
                checkAndNotifyTextEntrys(this, 'comorbidity');
            });
        });
        function ToggleOtherTextboxs(section) {
            $('.' + section + '-other-entry-toggle input').each(function (idx, itm) {
                if ($(this).is(':checked')) {
                    $('.' + section + '-other-text-entry').show();
                }
                else {
                    $('.' + section + '-other-text-entry').hide();


                }
            });
        }
        function checkAndNotifyTextEntrys(ctrl, section) {
            var checkedQty = 0;

            if ($(ctrl).is(':checked')) {
                //check if any other checkboxes have been ticked.
                $('.' + section + '-parent input').not(ctrl).each(function (idx, itm) {
                    if ($(itm).is(':checked')) {
                        checkedQty++;
                        return
                    }
                });

                if (checkedQty == 0) {
                    if (confirm('We strongly recommend against using free text entry over choosing a selected item as per National Data Set regulation. \n Do you still wish to continue?')) {
                        ToggleOtherTextboxs(section);
                        $('.' + section + '-free-entry-warning').show(); //display the free text entry warning message to show them we mean business -_-
                    }
                    else {
                        $(ctrl).prop('checked', false);
                        ToggleOtherTextboxs(section);
                        $('.' + section + '-other-text-entry').hide();
                    }
                }
                else {
                    ToggleOtherTextboxs(section);
                    $('.' + section + '-free-entry-warning').hide(); //no need to display the free text entry warning message
                }
            }
            else {
                ToggleOtherTextboxs(section);
                //clear text box
                $('.' + section + '-additional-info').val('');
            }
        }

        function childComorb_changed(sender, args) {
            var selectedValue = args.get_item().get_value();
            var comorbId = sender.get_attributes().getAttribute('data-comorbid');

            saveComorbidity(comorbId, selectedValue, true, '');
        }

        function saveComorbidity(comorbId, childId, checked, additionalInfo) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.preAssessmentId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PRE_ASSESSMENT_Id)%>);
            obj.comorbidityId = parseInt(comorbId);
            obj.childId = childId;
            obj.checked = checked;
            obj.additionalInfo = additionalInfo;
            isComorbidityChange = true;
            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/saveComorbidity",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function ()
                {
                    if (obj.procedureId > 0)
                    {
                        setRehideSummary();
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
        }
    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<div class="control-section-header abnorHeader com-top" id="ComorbidityHeader" runat="server">Comorbidity&nbsp;<img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" /></div>
<div class="control-content margin-com">

    <asp:Repeater ID="rptComorbidity" runat="server" OnItemDataBound="rptComorbidity_ItemDataBound">
        <HeaderTemplate>
            <table id="Tcomorbidity" class="DataBoundTable Fixed700TableWidth margin-bot" cellpadding="0" cellspacing="0">
                <tr>
        </HeaderTemplate>
        <ItemTemplate>
            <%# IIf(Container.ItemIndex Mod 2 = 0, "</tr><tr>", "")%>
            <td>
                <asp:CheckBox ID="DataCheckbox" runat="server" data-comorbid='<%# Eval("UniqueId") %>' Text='<%# Eval("Description") %>' CssClass="comorb-parent" />
            </td>
        </ItemTemplate>
        <FooterTemplate>
            </table>
        </FooterTemplate>
    </asp:Repeater>

    <div class="comorbidity-other-text-entry other-entry-section other-pad">
        <asp:Repeater ID="rptComorbidityAdditionalInfo" runat="server">
            <HeaderTemplate>
                <table class="AdditionalInfoTable" cellpadding="0" cellspacing="0" style="margin-top: 35px;">
                    <tr>
            </HeaderTemplate>
            <ItemTemplate>
                <%# IIf(Container.ItemIndex Mod 2 = 0, "</tr><tr>", "")%>
                <td style="vertical-align: top; padding-right: 20px;">
                    <asp:Label ID="lblAdditionalInfo" Text='<%# Eval("Description") %>' runat="server" CssClass="comorb-parent" />:<br />
                    <telerik:RadTextBox ID="txtAdditionalInfo" runat="server" TextMode="MultiLine" Width="450" Height="105" CssClass="comorbidity-additional-info" data-comorbid='<%# Eval("UniqueId") %>' /><br />
                    <strong class="comorbidity-free-entry-warning" style="color: red;">Please refrain from entering your information here. Choose from the list above instead</strong>
                </td>
            </ItemTemplate>
            <FooterTemplate>
                </table>
            </FooterTemplate>
        </asp:Repeater>
    </div>
</div>
