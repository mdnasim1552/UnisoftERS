<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="Indications.ascx.vb" Inherits="UnisoftERS.Indications" %>
<style type="text/css">
    .IndicationsTable td {
        width: 33.3%;
    }

    .gi-bleeds-button {
        margin-left: 5px;
    }

    .indications-child {
        margin-left: 10px;
    }

    .indications-fieldset {
        width: auto !important;
    }

    .indications-child-info {
        margin-left: 10px !important;
    }

    .searchButton {
        display: none
    }

    .repeat-result {
        display: none;
        float: left;
    }
</style>

<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;

        $(window).on('load', function () {
            //toggleRepeatResultSection();
            ToggleGIBleedsButton();
            ToggleOtherTextbox('indications');
            ToggleSubIndications();
            ToggleOtherTextbox('subindications');
            $(".subindications-parent input[type='checkbox']").each(function () {
                var classname = $(this).next('label').text().replace(/[^a-zA-Z0-9]/g, "_");//replace(/ /g, "_");
                if ($(this).prop('checked')) {
                    $("." + classname).closest(".rptItems").show();
                    if (classname != "Other") {
                        $("." + classname).closest(".subindications-free-entry-warning").hide();
                    }
                    //if ($("." + classname).length > 0) {

                    //}
                } else {
                    $("." + classname).closest(".rptItems").hide();
                    //if ($("." + classname).length > 0) {

                    //}
                }
            });
            $(".indications-parent input[type='checkbox']").each(function () {
                var classname = $(this).next('label').text().replace(/[^a-zA-Z0-9]/g, "_");//replace(/ /g, "_");
                if ($(this).prop('checked')) {
                    if ($("." + classname).length > 0) {
                        if (classname == "Other") {
                            $("." + classname + "_indication").closest(".rptItems").show();
                        } else {
                            $("." + classname).closest(".rptItems").show();
                            $("." + classname).closest(".indications-free-entry-warning").hide();
                        }
                    }
                } else {
                    if (classname == "Other") {
                        $("." + classname + "_indication").closest(".rptItems").hide();
                    } else {
                        $("." + classname).closest(".rptItems").hide();
                    }
                    //if ($("." + classname).length > 0) {

                    //}
                }
            });

            $(".surveillance-parent input[type='checkbox']").each(function () {
                var classname = $(this).next('label').text().replace(/[^a-zA-Z0-9]/g, "_");//replace(/ /g, "_");
                if ($(this).prop('checked')) {
                    if ($("." + classname).length > 0) {
                        if (classname == "Other") {
                            $("." + classname + "_surveillance").closest(".rptSurveillanceItems").show();
                        } else {
                            $("." + classname).closest(".rptSurveillanceItems").show();
                            $("." + classname).closest(".surveillance-free-entry-warning").hide();
                        }
                    }
                } else {
                    if (classname == "Other") {
                        $("." + classname + "_surveillance").closest(".rptSurveillanceItems").hide();
                    } else {
                        $("." + classname).closest(".rptSurveillanceItems").hide();
                    }
                    //if ($("." + classname).length > 0) {

                    //}
                }
            });
            $(".planned-parent input[type='checkbox']").each(function () {
                var classname = $(this).next('label').text().replace(/[^a-zA-Z0-9]/g, "_");//replace(/ /g, "_");
                if ($(this).prop('checked')) {
                    if ($("." + classname).length > 0) {
                        if (classname == "Other") {
                            $("." + classname + "_planned").closest(".rptPlannedItems").show();
                        } else {
                            $("." + classname).closest(".rptPlannedItems").show();
                            $("." + classname).closest(".planned-free-entry-warning").hide();
                        }
                    }
                } else {
                    if (classname == "Other") {
                        $("." + classname + "_planned").closest(".rptPlannedItems").hide();
                    } else {
                        $("." + classname).closest(".rptPlannedItems").hide();
                    }
                    //if ($("." + classname).length > 0) {

                    //}
                }
            });

        });

        $(document).ready(function () {
            //$('.AddDisplayNone').each(function (index, element) {
            //    console.log("TextBox Value:", index+" "+element.textContent);

            //});


            $("#<%= RepeatNotKnownRadComboBox.ClientID %>").change(function () {               
                if ($("#<%= RepeatNotKnownRadComboBox.ClientID %>_Input").val() == "Other") {
                    $('#<%=RepeatTextDiv.ClientID %>').show();
                } else {
                    $('#<%=RepeatTextDiv.ClientID %>').hide();
                    $('#<%=RepeatTextBox.ClientID %>').val('');
                }
                saveRepeatResult();
            });

            $('#<%= RepeatTextBox.ClientID %>').on('focusout', function () {
                saveRepeatResult();
            });

            $('.indications-child-info').on('focusout', function () {
                var indicationId = $(this).attr('data-indicationid');
                var childId = $(this)[0].id;
                var additionalInfoText = $(this).val();
                var checked = (additionalInfoText != '');

                saveIndication(indicationId, childId, checked, additionalInfoText);
            });

            $('.indications-additional-info').on('focusout', function () {
                var indicationId = $(this).attr('data-indicationid');
                var additionalInfoText = $(this).val();
                var checked = (additionalInfoText != '');

                saveIndication(indicationId, 0, checked, additionalInfoText);
            });
            $('.surveillance-additional-info').on('focusout', function () {
                var indicationId = $(this).attr('data-indicationid');
                var additionalInfoText = $(this).val();
                var checked = (additionalInfoText != '');

                saveIndication(indicationId, 0, checked, additionalInfoText);
            });
            $('.planned-additional-info').on('focusout', function () {
                var indicationId = $(this).attr('data-indicationid');
                var additionalInfoText = $(this).val();
                var checked = (additionalInfoText != '');

                saveIndication(indicationId, 0, checked, additionalInfoText);
            });
            $('.sub-indication-additional-info').on('focusout', function () {
                var indicationId = $(this).attr('data-subindicationid');
                var additionalInfoText = $(this).val();
                var checked = (additionalInfoText != '');

                saveSubIndication(indicationId, checked, additionalInfoText);
            });

            $('.subindications-parent input').on('change', function () {
                //auto save

                let id = $(this).closest('.subindications-parent').attr('data-subindicationid');
                var description = $(this).closest('.subindications-parent').text().trim().replace(/[^a-zA-Z0-9]/g, "_");
                var checked = $(this).is(':checked');
                var additionalInfo = '';
                if (checked) {

                    $("." + description).closest(".rptItems").show();
                    if (description != "Other") {
                        $("." + description).closest(".subindications-free-entry-warning").hide();
                    }

                } else {
                    $("." + description).closest(".rptItems").hide();//sub-indication-additional-info
                    $("." + description).closest(".sub-indication-additional-info").val('');
                }

                saveSubIndication(id, checked, additionalInfo);
            });

            $('.indications-parent input').not('.toggle input').on('change', function () {
                var childControl = $(this).closest('td').find('.indications-child');
                if (childControl.length > 0) {
                    if ($(this).is(':checked')) {
                        $(childControl).show();
                    }
                    else {
                        $(childControl).hide();
                        var comboBox = $find(childControl.attr('id')); // Get RadComboBox control instance
                        if (comboBox) {
                            comboBox.clearSelection(); // Clear the selection
                        }
                    }
                }

                //auto save
                var id = $(this).closest('td').find('.indications-parent').attr('data-indicationid');
                var description = $(this).closest('.indications-parent').text().trim().replace(/[^a-zA-Z0-9]/g, "_");
                var checked = $(this).is(':checked');
                if (checked) {
                    var checkedQty = 0;
                    //check if any other checkboxes have been ticked.
                    $('.indications-parent input').each(function (idx, itm) {
                        if ($(itm).is(':checked')) {
                            checkedQty++;
                            return
                        }
                    });
                    if (checkedQty <= 1 && description == "Other") {
                        if (confirm('We strongly recommend against using free text entry over choosing a selected item as per National Data Set regulation. \n Do you still wish to continue?')) {
                            $("." + description + "_indication").closest(".rptItems").show();
                            $("." + description + "_indication").closest(".indications-free-entry-warning").hide();
                        }
                    } else {
                        if (description == "Other") {
                            $("." + description + "_indication").closest(".rptItems").show();

                        } else {
                            $("." + description).closest(".rptItems").show();
                            if (description != "Other") {
                                $("." + description).closest(".indications-free-entry-warning").hide();
                            }
                        }
                    }
                } else {
                    if (description == "Other") {
                        $("." + description + "_indication").closest(".rptItems").hide();//sub-indication-additional-info
                        $("." + description + "_indication").closest(".indications-additional-info").val('');
                    } else {
                        $("." + description).closest(".rptItems").hide();//sub-indication-additional-info
                        $("." + description).closest(".indications-additional-info").val('');
                    }

                }
                saveIndication(id, 0, checked, '');
            });

            $('.surveillance-parent input').not('.toggle input').on('change', function () {
                var childControl = $(this).closest('td').find('.indications-child');
                if (childControl.length > 0) {
                    if ($(this).is(':checked')) {
                        $(childControl).show();
                    }
                    else {
                        $(childControl).hide();
                        var comboBox = $find(childControl.attr('id')); // Get RadComboBox control instance
                        if (comboBox) {
                            comboBox.clearSelection(); // Clear the selection
                        }
                    }
                }

                //auto save
                var id = $(this).closest('td').find('.surveillance-parent').attr('data-indicationid');
                var description = $(this).closest('.surveillance-parent').text().trim().replace(/[^a-zA-Z0-9]/g, "_");
                var checked = $(this).is(':checked');
                if (checked) {
                    var checkedQty = 0;
                    //check if any other checkboxes have been ticked.
                    $('.surveillance-parent input').each(function (idx, itm) {
                        if ($(itm).is(':checked')) {
                            checkedQty++;
                            return
                        }
                    });
                    if (checkedQty <= 1 && description == "Other") {
                        if (confirm('We strongly recommend against using free text entry over choosing a selected item as per National Data Set regulation. \n Do you still wish to continue?')) {
                            $("." + description + "_surveillance").closest(".rptSurveillanceItems").show();
                            $("." + description + "_surveillance").closest(".surveillance-free-entry-warning").hide();
                        }
                    } else {
                        if (description == "Other") {
                            $("." + description + "_surveillance").closest(".rptSurveillanceItems").show();

                        } else {
                            $("." + description).closest(".rptSurveillanceItems").show();
                            if (description != "Other") {
                                $("." + description).closest(".surveillance-free-entry-warning").hide();
                            }
                        }
                    }
                } else {
                    if (description == "Other") {
                        $("." + description + "_surveillance").closest(".rptSurveillanceItems").hide();//sub-indication-additional-info
                        $("." + description + "_surveillance").closest(".surveillance-additional-info").val('');
                    } else {
                        $("." + description).closest(".rptSurveillanceItems").hide();//sub-indication-additional-info
                        $("." + description).closest(".surveillance-additional-info").val('');
                    }

                }
                saveIndication(id, 0, checked, '');
            });

            $('.planned-parent input').not('.toggle input').on('change', function () {
                var childControl = $(this).closest('td').find('.indications-child');
                if (childControl.length > 0) {
                    if ($(this).is(':checked')) {
                        $(childControl).show();
                    }
                    else {
                        $(childControl).hide();
                        var comboBox = $find(childControl.attr('id')); // Get RadComboBox control instance
                        if (comboBox) {
                            comboBox.clearSelection(); // Clear the selection
                        }
                    }
                }

                //auto save
                var id = $(this).closest('td').find('.planned-parent').attr('data-indicationid');
                var description = $(this).closest('.planned-parent').text().trim().replace(/[^a-zA-Z0-9]/g, "_");
                var checked = $(this).is(':checked');
                if (checked) {
                    var checkedQty = 0;
                    //check if any other checkboxes have been ticked.
                    $('.planned-parent input').each(function (idx, itm) {
                        if ($(itm).is(':checked')) {
                            checkedQty++;
                            return
                        }
                    });
                    if (checkedQty <= 1 && description == "Other") {
                        if (confirm('We strongly recommend against using free text entry over choosing a selected item as per National Data Set regulation. \n Do you still wish to continue?')) {
                            $("." + description + "_planned").closest(".rptPlannedItems").show();
                            $("." + description + "_planned").closest(".planned-free-entry-warning").hide();
                        }
                    } else {
                        if (description == "Other") {
                            $("." + description + "_planned").closest(".rptPlannedItems").show();

                        } else {
                            $("." + description).closest(".rptPlannedItems").show();
                            if (description != "Other") {
                                $("." + description).closest(".planned-free-entry-warning").hide();
                            }
                        }
                    }
                } else {
                    if (description == "Other") {
                        $("." + description + "_planned").closest(".rptPlannedItems").hide();//sub-indication-additional-info
                        $("." + description + "_planned").closest(".planned-additional-info").val('');
                    } else {
                        $("." + description).closest(".rptPlannedItems").hide();//sub-indication-additional-info
                        $("." + description).closest(".planned-additional-info").val('');
                    }

                }
                saveIndication(id, 0, checked, '');
            });

            $('.indications-other-entry-toggle input').on('change', function () {
                checkAndNotifyTextEntry(this, 'indications');
            });

            $('.subindications-other-entry-toggle input').on('change', function () {
                checkAndNotifyTextEntry(this, 'subindications');
            });

            $('.gi-data-toggle input').on('change', function () {
                ToggleGIBleedsButton();
            });
        });
        function ToggleGIBleedsButton() {
            $('.gi-data-toggle input').each(function (idx, itm) {
                if ($(this).is(':checked')) {
                    $(this).closest('td').find('.gi-bleeds-button').show();
                }
                else {
                    $(this).closest('td').find('.gi-bleeds-button').hide();
                }
            });
        }

        function openGIBleedsPopUp() {
            var own = radopen("Gastro/OtherData/OGD/GIBleeds.aspx", "GI Bleeds", '865px', '700px');
            own.set_visibleStatusbar(false);
            own.add_close(GIBleedsClose);
        }

        function GIBleedsClose() {
            setRehideSummary();
        }

        function ToggleSubIndications() {
            if ($('.sub-indication-parent input').is(':checked')) {

                $('.sub-indications').show();

                //hide all sub indications so we can turn them on individually below depending on what indication has been selected
                $('.subindications-parent').closest('td').hide();


                $('.sub-indication-parent').each(function (idx, itm) {
                    if ($(this).find('input').is(':checked')) {

                        var indicationId = $(itm).attr("data-indicationId");
                        $('.subindications-parent[data-indicationid=' + indicationId + ']').each(function (idx, itm) {
                            $(itm).closest('td').show();
                        });
                    }
                });
            }
            else {
                var indicationId = $(this).attr("indicationId");

                $('.sub-indications').hide();
                deleteSubIndications();
            }
        }

        function childIndication_changed(sender, args) {
            var selectedValue = args.get_item().get_value();
            var indicationId = sender.get_attributes().getAttribute('data-indicationid');

            saveIndication(indicationId, selectedValue, true, '');
        }

        function saveIndication(indicationId, childId, checked, additionalInfo) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.indicationId = parseInt(indicationId);
            obj.childId = childId;
            obj.checked = checked;
            obj.additionalInfo = additionalInfo;

            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/saveIndication",
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

        function deleteSubIndications() {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);

            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/deleteSubIndications",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    setRehideSummary();
                },
                error: function (x, y, z) {
                    autoSaveSuccess = false;
                    //show a message

                }
            });
        }

        function saveSubIndication(subIndicationId, checked, additionalInfo) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.subIndicationId = parseInt(subIndicationId);
            obj.checked = checked;
            obj.additionalInfo = additionalInfo;

            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/saveSubIndication",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    setRehideSummary();
                },
                error: function (x, y, z) {
                    autoSaveSuccess = false;
                    //show a message

                }
            });
        }

        function saveRepeatResult() {
            var selectedAnswer = $('#<%=RepeatRadioButtonList.ClientID%> input:checked').val();
            var repeatUnknownValue = parseInt($find('<%= RepeatNotKnownRadComboBox.ClientID %>').get_value()) || 0;
            var otherTextValue = $('#<%= RepeatTextBox.ClientID %>').val();
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.selectedAnswer = selectedAnswer == 1 ? true : false;
            obj.repeatUnknownValue = repeatUnknownValue;
            obj.otherTextValue = otherTextValue;

            //console.log(obj.selectedAnswer + ', ' + repeatUnknownValue + ' & ' + otherTextValue)

            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/saveRepeatProcedure",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    refreshSummary();
                },
                error: function (x, y, z) {

                }
            });
        }

        function toggleRepeatResultSection() {
            if ($('#<%=RepeatRadioButtonList.ClientID%> input:checked').val() == '1') {
                $('#<%=RepeatUnknownDiv.ClientID%>').show();
            }
            else {
                $('#<%=RepeatUnknownDiv.ClientID%>').hide();
                
            }
        }

    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<div class="control-section-header abnorHeader">Indications&nbsp;<img src="../Images/NEDJAG/Ned.png" alt="NED Mandatory Field" /></div>

<div id="RepeatProcedureDiv" runat="server" class="control-content" visible="false">
    <table>
        <tr>
            <td>Is this a repeat procedure?</td>
            <td>
                <asp:RadioButtonList ID="RepeatRadioButtonList" runat="server" AutoPostBack="false" RepeatDirection="Horizontal">
                    <asp:ListItem Value="1" Text="Yes" />
                    <asp:ListItem Value="0" Text="No" />
                </asp:RadioButtonList>
            </td>

            <td style="padding-left: 10px;">
                <div id="RepeatUnknownDiv" runat="server" class="repeat-result" style="display: none;">
                    <telerik:RadComboBox ID="RepeatNotKnownRadComboBox" Text="Formation:" runat="server" Width="200" Skin="Metro" AutoPostBack="false" AppendDataBoundItems="true" DataTextField="Description" DataValueField="UniqueId" OnClientSelectedIndexChanged="saveRepeatResult" >
                        <Items>
                            <telerik:RadComboBoxItem Text="" Value="0" />
                        </Items>
                    </telerik:RadComboBox>
                </div>
            </td>

            <td style="padding-left: 5px;">
                <div id="RepeatTextDiv" runat="server" style="display: none;">
                    <telerik:RadTextBox ID="RepeatTextBox" runat="server" AutoPostBack="true" style="border: 1px solid #ccc;" />
                </div>
            </td>
        </tr>
    </table>
</div>

<div class="control-content" runat="server" id="rptSurveillanceDiv">

    <asp:Repeater ID="rptSurveillance" runat="server" OnItemDataBound="rptSurveillance_ItemDataBound">
        <ItemTemplate>

            <div class="control-sub-header" style="margin-left: 0px; margin-bottom: 5px;">
                <asp:Label ID="SectionNameLabel" runat="server" Text='<%#Eval("SectionName") %>' />
            </div>
            <asp:Repeater ID="rptSurveillanceIndications" runat="server" OnItemDataBound="rptSurveillanceIndications_ItemDataBound">
                <HeaderTemplate>
                    <table class="IndicationsTable Fixed700TableWidth" cellpadding="0" cellspacing="0">
                        <tr>
                </HeaderTemplate>
                <ItemTemplate>
                    <%--Mahfuz changed Mod 3 = 0 to Mod 2 = 0--%>
                    <%# IIf(Container.ItemIndex Mod 2 = 0, "</tr><tr>", "")%>
                    <td>
                        <asp:CheckBox ID="IndicationCheckbox" runat="server" data-indicationid='<%# Eval("UniqueId") %>' data-jagauditable='<%# Eval("JagAuditable") %>' Text='<%# Eval("Description") %>' CssClass="surveillance-parent" />
                    </td>
                </ItemTemplate>
                <FooterTemplate>
                    </tr>
                </table>
                </FooterTemplate>
            </asp:Repeater>

            <div class="indications-other-text-entry other-entry-section">
                <asp:Repeater ID="rptSurveillanceAdditionalInfo" runat="server" Visible="<%# (Container.ItemIndex = 0) %>" OnItemDataBound="rptSurveillanceAdditionalInfo_ItemDataBound">
                    <HeaderTemplate>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div class="rptSurveillanceItems">
                            <asp:Label ID="lblAdditionalInfo" Text='<%# Eval("Description") %>' runat="server" CssClass="surveillance-parent" />:<br />
                            <telerik:RadTextBox ID="txtAdditionalInfo" runat="server" TextMode="MultiLine" Width="450" Height="105" CssClass=" surveillance-parent surveillance-additional-info" data-indicationid='<%# Eval("UniqueId") %>' /><br />
                            <strong runat="server" class="surveillance-free-entry-warning" style="color: red;">Please refrain from entering your information here. Choose from the list above instead</strong>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                    </FooterTemplate>
                </asp:Repeater>
            </div>

        </ItemTemplate>
    </asp:Repeater>


</div>

<div class="control-content" runat="server" id="rptSectionsDiv">

    <asp:Repeater ID="rptSections" runat="server" OnItemDataBound="ParentRepeater_ItemDataBound">
        <ItemTemplate>

            <div class="control-sub-header" style="margin-left: 0px; margin-bottom: 5px;">
                <asp:Label ID="SectionNameLabel" runat="server" Text='<%#Eval("SectionName") %>' />
            </div>
            <asp:Repeater ID="rptIndications" runat="server" OnItemDataBound="rptIndications_ItemDataBound">
                <HeaderTemplate>
                    <table class="IndicationsTable Fixed700TableWidth" cellpadding="0" cellspacing="0">
                        <tr>
                </HeaderTemplate>
                <ItemTemplate>
                    <%--Mahfuz changed Mod 3 = 0 to Mod 2 = 0--%>
                    <%# IIf(Container.ItemIndex Mod 2 = 0, "</tr><tr>", "")%>
                    <td>
                        <asp:CheckBox ID="IndicationCheckbox" runat="server" data-indicationid='<%# Eval("UniqueId") %>' data-jagauditable='<%# Eval("JagAuditable") %>' Text='<%# Eval("Description") %>' CssClass="indications-parent" />
                    </td>
                </ItemTemplate>
                <FooterTemplate>
                    </tr>
                </table>
                </FooterTemplate>
            </asp:Repeater>
            <div class="indications-other-text-entry other-entry-section">
                <asp:Repeater ID="rptIndicationsAdditionalInfo" runat="server" Visible="<%# (Container.ItemIndex = 0) %>" OnItemDataBound="rptIndicationsAdditionalInfo_ItemDataBound">
                    <HeaderTemplate>
                        <%--<table class="AdditionalInfoTable Fixed700TableWidth" cellpadding="0" cellspacing="0" style="margin-top: 15px; margin-bottom: 20px;">
                            <tr>--%>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div class="rptItems">
                            <asp:Label ID="lblAdditionalInfo" Text='<%# Eval("Description") %>' runat="server" CssClass="indications-parent" />:<br />
                            <telerik:RadTextBox ID="txtAdditionalInfo" runat="server" TextMode="MultiLine" Width="450" Height="105" CssClass=" indications-parent indications-additional-info" data-indicationid='<%# Eval("UniqueId") %>' /><br />
                            <strong runat="server" class="indications-free-entry-warning" style="color: red;">Please refrain from entering your information here. Choose from the list above instead</strong>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        <%--</tr>
                         </table>--%>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </ItemTemplate>
    </asp:Repeater>


</div>
<div class="sub-indications" style="display: none;" runat="server" id="rptSubIndicationsDiv" tabindex="-1" clientidmode="Static">

    <div class="control-sub-header">Sub indications</div>
    <div class="control-content">

        <asp:Repeater ID="rptSubIndications" runat="server">
            <HeaderTemplate>
                <table class="IndicationsTable Fixed700TableWidth" cellpadding="0" cellspacing="0">
                    <tr>
            </HeaderTemplate>
            <ItemTemplate>
                <!-- add required additional TDs here to even out the length-->
                <%# IIf(Container.ItemIndex Mod 2 = 0, "</tr><tr>", "")%>
                <td>
                    <asp:CheckBox ID="SubIndicationCheckbox" runat="server" data-subindicationid='<%# Eval("UniqueId") %>' Text='<%# Eval("Description") %>' CssClass="subindications-parent" data-indicationId='<%# Eval("IndicationId") %>' />
                </td>


            </ItemTemplate>
            <FooterTemplate>
                </tr>
                 </table>
            </FooterTemplate>
        </asp:Repeater>

        <div id="TextBoxOther" class="subindications-other-text-entry other-entry-section">

            <asp:Repeater ID="rptSubIndicationsAdditionalInfo" runat="server" OnItemDataBound="rptSubIndicationsAdditionalInfo_ItemDataBound">
                <HeaderTemplate>
                    <%--<table class="AdditionalInfoTable" cellpadding="0" cellspacing="0" style="margin-top: 35px;">
                        <tr>--%>
                </HeaderTemplate>
                <ItemTemplate>
                    <%--<%# IIf(Container.ItemIndex Mod 1 = 0, "</tr><tr>", "")%>--%>
                    <%-- <td style="vertical-align: top; padding-right: 20px;" CssClass="AddDisplayNone"  >--%>
                    <%--<asp:TextBox ID="TextBox1" runat="server" ClientIDMode="Static" CssClass="textBoxClass" Text='<%# Eval("Description") %>' Style="display:none;"></asp:TextBox>--%>
                    <div class="rptItems">
                        <br />
                        <asp:Label ID="lblAdditionalInfo" Text='<%# Eval("Description") %>' runat="server" CssClass="subindications-parent AddDisplayNone" data-indicationId='<%# Eval("IndicationId") %>' /><br />
                        <telerik:RadTextBox ID="txtAdditionalInfo" runat="server" TextMode="MultiLine" Width="450" Height="105" CssClass="subindications-parent AddDisplayNone sub-indication-additional-info" data-subindicationid='<%# Eval("UniqueId") %>' data-indicationId='<%# Eval("IndicationId") %>' /><br />
                        <strong runat="server" class="subindications-free-entry-warning AddDisplayNone" style="color: red;">Please refrain from entering your information here. Choose from the list above instead</strong>
                    </div>

                    <%--</td>--%>
                </ItemTemplate>
                <FooterTemplate>
                    <%-- </tr>
                        </table>--%>
                </FooterTemplate>
            </asp:Repeater>
        </div>

    </div>
</div>

<div class="control-content" runat="server" id="rptSectionsPlannedDiv">

    <asp:Repeater ID="rptSectionsPlanned" runat="server" OnItemDataBound="rptSectionsPlanned_ItemDataBound">
        <ItemTemplate>

            <div class="control-sub-header" style="margin-left: 0px; margin-bottom: 5px;">
                <asp:Label ID="SectionNameLabel" runat="server" Text='<%#Eval("SectionName") %>' />
            </div>
            <asp:Repeater ID="rptPlannedIndications" runat="server" OnItemDataBound="rptPlannedIndications_ItemDataBound">
                <HeaderTemplate>
                    <table class="IndicationsTable Fixed700TableWidth" cellpadding="0" cellspacing="0">
                        <tr>
                </HeaderTemplate>
                <ItemTemplate>
                    <%--Mahfuz changed Mod 3 = 0 to Mod 2 = 0--%>
                    <%# IIf(Container.ItemIndex Mod 2 = 0, "</tr><tr>", "")%>
                    <td>
                        <asp:CheckBox ID="IndicationCheckbox" runat="server" data-indicationid='<%# Eval("UniqueId") %>' data-jagauditable='<%# Eval("JagAuditable") %>' Text='<%# Eval("Description") %>' CssClass="planned-parent" />
                    </td>
                </ItemTemplate>
                <FooterTemplate>
                    </tr>
                </table>
                </FooterTemplate>
            </asp:Repeater>
            <div class="indications-other-text-entry other-entry-section">
                <asp:Repeater ID="rptPlannedIndicationsAdditionalInfo" runat="server" Visible="<%# (Container.ItemIndex = 0) %>" OnItemDataBound="rptPlannedIndicationsAdditionalInfo_ItemDataBound">
                    <HeaderTemplate>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div class="rptPlannedItems">
                            <asp:Label ID="lblAdditionalInfo" Text='<%# Eval("Description") %>' runat="server" CssClass="planned-parent" />:<br />
                            <telerik:RadTextBox ID="txtAdditionalInfo" runat="server" TextMode="MultiLine" Width="450" Height="105" CssClass=" planned-parent planned-additional-info" data-indicationid='<%# Eval("UniqueId") %>' /><br />
                            <strong runat="server" class="planned-free-entry-warning" style="color: red;">Please refrain from entering your information here. Choose from the list above instead</strong>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </ItemTemplate>
    </asp:Repeater>


</div>
