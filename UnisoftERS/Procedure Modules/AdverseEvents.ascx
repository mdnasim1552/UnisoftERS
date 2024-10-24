<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="AdverseEvents.ascx.vb" Inherits="UnisoftERS.AdverseEvents" %>
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
</style>

<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;
        var bleedingTextBoxId;       
        $(window).on('load', function () {
            ToggleOtherTextbox('adverseevent');
        });

        $(document).ready(function () {
            $('.adverseevent-child-info').on('focusout', function () {
                var adverseEventId = $(this).attr('data-adverseeventid');
                var childId = $(this)[0].id;
                var additionalInfoText = $(this).val();
                var checked = (additionalInfoText != '');
                saveAdverseEvent(adverseEventId, childId, checked, additionalInfoText);
            });

            $('.adverseevent-additional-info').on('focusout', function () {

                var adverseEventId = $(this).attr('data-adverseeventid');
                bleedingTextBoxId = adverseEventId
                var additionalInfoText = $(this).val();
                var checked = (additionalInfoText != '');
                saveAdverseEvent(adverseEventId, 0, true, additionalInfoText);
            });

            $('.adverseevent-parent input').on('change', function () {
                var childControl = $(this).closest('td').find('.adverseevent-child');
                if (childControl.length > 0) {
                    if ($(this).is(':checked')) {
                        $(childControl).show();
                    }
                    else {
                        $(childControl).hide();
                        $(childControl).val('');
                    }
                }
                
                //auto save
                var id = $(this).closest('td').find('.adverseevent-parent').attr('data-adverseeventid');
                var checked = $(this).is(':checked');                
                var radComboBox;
                var comboBoxSelector;
                //var CheckedText = $(this).parent().text().trim(); // 4321 starts
                var isBleedingChecked;
                $('.adverseevent-parent').each(function (idx, itm) {
                    
                    var checkboxText = $(itm).text().trim();
                    if (checkboxText === "Bleeding") {
                        isBleedingChecked = $(itm).find('input[type="checkbox"]').is(':checked');
                        comboBoxSelector = '.adverseevent-child[data-adverseeventid="' + id + '"]';
                        radComboBox = $find($(comboBoxSelector).attr('id'));
                    }
                    $('.adverseevent-child').each(function () {
                        if (isBleedingChecked && checkboxText === "Bleeding") {                      
                                if (radComboBox) {
                                    var selectedText = radComboBox.get_selectedItem()?.get_text() || '';
                                    if (selectedText === "Other") {
                                        OtherBleedingBoxShow();
                                    }
                                    //else {
                                    //  // OtherBleedingBoxHide();
                                    //}
                                }
                        }
                    });
                    $('.adverseevent-child').each(function () {
                    if (!isBleedingChecked && checkboxText === "Bleeding") {
                            if (radComboBox) {
                                radComboBox.clearSelection(); // Clear the specific RadComboBox
                            }
                            OtherBleedingBoxHide();
                        }
                    });

                });
                // 4321 end
                saveAdverseEvent(id, 0, checked, '');

                //untick none
                if ($(this).closest('span').text().toLowerCase() != 'none') {

                    $(".adverseevent-none input").prop('checked', false);
                    var noneID = $(".adverseevent-none").attr('data-adverseeventid');
                    saveAdverseEvent(noneID, 0, false, '');
                }
                else { //untick all
                    if (checked) {

                        $(".adverseevent-parent input:checked").not('.adverseevent-none input').each(function (idx, itm) {
                            $(this).prop('checked', false);
                        });

                        //hide child controls
                        $('.adverseevent-child').each(function (itm, idx) {
                            $(this).hide();
                            $(this).val('');
                        })
                        //hode other textbox
                        $('.adverseevent-other-text-entry').hide();
                    }

                }
            });
            $('.adverseevent-other-entry-toggle input').on('change', function () {                          
                checkAndNotifyTextEntry(this, 'adverseevent');
            });
        });

        function childAdverseEvent_changed(sender, args) {
            var selectedValue = args.get_item().get_value();
            var selectedText = args.get_item().get_text(); // 4321 starts
            if (selectedText == 'Other') {
                $('.adverseevent-parent').each(function (idx, itm) {
                    var checkboxText = $(itm).text().trim();
                    if (checkboxText === "Other" || checkboxText === "Other complication") {
                        var isChecked = $(itm).find('input[type="checkbox"]').is(':checked');
                        if (isChecked) {                           
                            var label = $('.checkValues').find('.indications-parent');
                            var radTextBoxes = $('.checkValues').find('.adverseevent-additional-info');
                            var warning = $('.checkValues').find('.adverseevent-free-entry-warning');
                                label.each(function (labelIdx, labelItem) {                                   
                                    $(labelItem).show();
                                    $(radTextBoxes[labelIdx]).show();
                                    $(warning[labelIdx]).show();
                                    var escapedLabelValue = $(labelItem).text().replace(/ /g, '\\ ');
                                    $('#OtherBoxTD_' + escapedLabelValue).css('display', 'table-cell');  
                                    if ($(labelItem).text() === "Other Bleeding Text") {
                                        var adverseEvent_Id = $('.checkValues').find('.adverseevent-additional-info').eq(1).attr('data-adverseeventid');
                                        saveAdverseEvent(adverseEvent_Id, 0, true, '');
                                    }

                                    
                                });
                        }
                        else {
                                var label = $('.checkValues').find('.indications-parent');                              
                            var radTextBoxes = $('.checkValues').find('.adverseevent-additional-info');
                            var warning = $('.checkValues').find('.adverseevent-free-entry-warning');
                                label.each(function (labelIdx, labelItem) {
                                    var labelValue = $(labelItem).text();                                  
                                    if (labelValue === "Other" || labelValue === "Other complication") {
                                        $(labelItem).hide();
                                        $(radTextBoxes[labelIdx]).hide();
                                        $(radTextBoxes[labelIdx]).val('');
                                        $(warning[labelIdx]).hide(); 
                                        $('#OtherBoxTD_' + labelValue).css('display', 'none');                                        
                                    }
                                    if (labelValue === "Other Bleeding Text") {
                                        $(labelItem).show();
                                        $(radTextBoxes[labelIdx]).show();
                                        $(warning[labelIdx]).show();   
                                        var escapedLabelValue = labelValue.replace(/ /g, '\\ ');
                                        $('#OtherBoxTD_' + escapedLabelValue).css('display', 'table-cell');      
                                        var adverseEvent_Id = $('.checkValues').find('.adverseevent-additional-info').eq(1).attr('data-adverseeventid');    
                                       saveAdverseEvent(adverseEvent_Id, 0, true, '');
                                    }
                                }); 
                                //$('.adverseevent-other-text-entry').show();
                        }
                    }
                });
            }
            else {
                $('.adverseevent-parent').each(function (idx, itm) {
                    var checkboxText = $(itm).text().trim();                          
                        var isChecked = $(itm).find('input[type="checkbox"]').is(':checked');
                    if (isChecked && (checkboxText === "Other" || checkboxText === "Other complication")) {
                        var id = $(this).closest('td').find('.adverseevent-parent').attr('data-adverseeventid');
                        comboBoxSelector = '.adverseevent-child[data-adverseeventid="' + id + '"]';
                        radComboBox = $find($(comboBoxSelector).attr('id'));
                        $('.adverseevent-child').each(function () {
                            if (radComboBox) {
                                var selectedText = radComboBox.get_selectedItem()?.get_text() || '';
                                if (selectedText === "Other") {
                                    OtherBleedingBoxShow();
                                } else {
                                    OtherBleedingBoxHide();
                                }
                            }
                        });
                        OtherBoxShow();
                    }
                    if (isChecked && (checkboxText === "Bleeding") )
                    {
                        var id = $(this).closest('td').find('.adverseevent-parent').attr('data-adverseeventid');
                        comboBoxSelector = '.adverseevent-child[data-adverseeventid="' + id + '"]';
                        radComboBox = $find($(comboBoxSelector).attr('id'));
                        $('.adverseevent-child').each(function () {                       
                                if (radComboBox) {
                                    var selectedText = radComboBox.get_selectedItem()?.get_text() || '';
                                    if (selectedText === "Other") {
                                        OtherBleedingBoxShow();
                                    } else {
                                        OtherBleedingBoxHide();
                                    }
                                }                            
                        });
                      }
                });
            }
            // 4321 ends
            var adverseEventId = sender.get_attributes().getAttribute('data-adverseeventid');           
            saveAdverseEvent(adverseEventId, selectedValue, true, '');
        }

        function saveAdverseEvent(adverseEventId, childId, checked, additionalInfo) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.adverseEventId = parseInt(adverseEventId);
            obj.childId = parseInt(childId);
            obj.checked = checked;
            obj.additionalInfo = additionalInfo;



            $.ajax({
                type: "POST",
                url: "PostProcedure.aspx/saveAdverseEvents",
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
    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />

<div class="control-section-header abnorHeader" runat="server" id="AdverseEventsHeader">Adverse events&nbsp;<img src="../Images/NEDJAG/NEDMand.png" alt="NED/ Mandatory Field" /></div>
<div class="control-content" runat="server" id="AdverseEventsContent">
    <asp:Repeater ID="rptAdverseEvents" runat="server" OnItemDataBound="rptAdverseEvents_ItemDataBound">
        <HeaderTemplate>
            <table class="DataBoundTable Fixed700TableWidth" cellpadding="0" cellspacing="0">
                <tr>
        </HeaderTemplate>
        <ItemTemplate>
            <%# IIf(Container.ItemIndex Mod 2 = 0, "</tr><tr>", "")%>
            <td>
                <asp:CheckBox ID="DataCheckbox" runat="server" data-adverseeventid='<%# Eval("UniqueId") %>' Text='<%# Eval("Description") %>' CssClass="adverseevent-parent" />
            </td>
        </ItemTemplate>
        <FooterTemplate>
            </table>
        </FooterTemplate>
    </asp:Repeater>

    <div class="adverseevent-other-text-entry other-entry-section checkValues">
        <asp:Repeater ID="rptAdverseEventsAdditionalInfo" runat="server">
            <HeaderTemplate>
                <table class="AdditionalInfoTable Fixed700TableWidth" cellpadding="0" cellspacing="0" style="">
                    <tr id="OtherBoxTR">
            </HeaderTemplate>
            <ItemTemplate>
                <%# IIf(Container.ItemIndex Mod 2 = 1, "</tr><tr>", "")%>
                <td id='<%# "OtherBoxTD_" & Eval("Description") %>' style="vertical-align: top; padding-right: 20px;">
                        <br />
                        <asp:Label ID="lblAdditionalInfo" Text='<%# Eval("Description") %>' runat="server" CssClass="indications-parent" /><br />
                        <telerik:RadTextBox ID="txtAdditionalInfo" runat="server"  TextMode="MultiLine" Width="450" Height="105" CssClass="adverseevent-additional-info" data-adverseeventid='<%# Eval("UniqueId") %>' /><br />
                        <br />
                        <strong class="adverseevent-free-entry-warning" style="color: red;">Please refrain from entering your information here. Choose from the list above instead</strong>
                </td>
            </ItemTemplate>
            <FooterTemplate>
                </tr>
                </table>
            </FooterTemplate>
        </asp:Repeater>
    </div>
</div>
