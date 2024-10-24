<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="Management.ascx.vb" Inherits="UnisoftERS.Management" %>
<style type="text/css">
    .DataBoundTable td {
        width: 33.3%;
    }

    .gi-bleeds-button {
        margin-left: 5px;
    }

    .management-child {
        margin-left: 10px;
        display: none;
    }

    .checkboxesTable td {
        padding-right: 10px;
        padding-bottom: 3px;
    }

    .auto-style1 {
        width: 230px;
    }

    .textbox {
        display: block;
    }

    .RadWindow .rwWindowContent .radalert 
    { 
        background-image: url(../../images/accept-24x24.png) !important; 
    } 
</style> 
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;
        let saveDefault = false  //added by Ferdowsi
        $(window).on('load', function () {
            Toggle($("#<%= OxygenationCheckBox.ClientID%>").is(':checked'), 'OxygenationMethodTD');
            Toggle($("#<%= ManagementOtherCheckBox.ClientID%>").is(':checked'), 'ManagementOtherTextBox');  /*edited by ferdowsi*/
            Toggle($("#<%= BPCheckBox.ClientID%>").is(':checked'), 'BPDetailsDiv');
            $('.man-rbl input').on('change', function () {
                saveManagement();
            });

            $('.man-tb').on('focusout', function () {
                var OxygenationFlowRate = parseFloat($('#<%=OxygenationFlowRateTextBox.ClientID%>').val());
                var BPSystolic = parseFloat($('#<%=BPSysTextBox.ClientID%>').val());
                var BPDiastolic = parseFloat($('#<%=BPDiaTextBox.ClientID%>').val());
                var errorMsg = '';
                if (OxygenationFlowRate !== null && OxygenationFlowRate !== undefined && OxygenationFlowRate > 15) {
                    <%--ar originalValue = $find('<%=OxygenationFlowRateTextBox.ClientID%>')._originalInitialValueAsText;
                    $('#<%=OxygenationFlowRateTextBox.ClientID%>').val(originalValue);--%>
                    setTimeout(function () {
                        $('#ProcManagement_OxygenationFlowRateTextBox').css('border-color', 'red');
                    }, 1);
                    errorMsg = 'Oxygenation Flow rate must be less than 15';
                } else if (BPSystolic !== null && BPSystolic !== undefined && (BPSystolic < 0 || BPSystolic > 300)) {
                    <%--var originalValue = $find('<%=BPSysTextBox.ClientID%>')._originalInitialValueAsText;
                    $('#<%=BPSysTextBox.ClientID%>').val(originalValue);--%>
                    setTimeout(function () {
                        $('#ProcManagement_BPSysTextBox').css('border-color', 'red');
                    }, 1);
                    errorMsg = 'Systolic must be between 0 to 300';
                } else if (BPDiastolic !== null && BPDiastolic !== undefined && (BPDiastolic < 0 || BPDiastolic > 300)) {
                    <%--var originalValue = $find('<%=BPDiaTextBox.ClientID%>')._originalInitialValueAsText;
                    $('#<%=BPDiaTextBox.ClientID%>').val(originalValue);--%>
                    setTimeout(function () {
                        $('#ProcManagement_BPDiaTextBox').css('border-color', 'red');
                    }, 1);
                    errorMsg = 'Diastolic must be between 0 to 300';
                } else
                    saveManagement();
                if (errorMsg !== '') {
                    $find('<%=RadNotification1.ClientID%>').set_text(errorMsg);
                    $find('<%=RadNotification1.ClientID%>').show();
                }
            });
        });

        $(document).ready(function () {
            $("#" + "<%= ManagementTable.ClientID%>" + " input:checkbox").change(function () {
                if ($(this).is(':checked')) {
                    var chkBoxId = $(this).attr("id");
                    if (chkBoxId.indexOf("ManagementNoneCheckBox") > -1) {
                        ClearControls("<%= ManagementTable.ClientID%>", chkBoxId);
                        $('*[id*=OxygenationMethodTD]').hide();
                        $('*[id*=ManagementOtherTD]').hide();
                        ClearControls("<%= BPDetailsDiv.ClientID%>", chkBoxId);
                        $('*[id*=BPDetailsDiv]').hide();
                        $("#" + "<%= ManagementTable.ClientID%>" + " input:checkbox").prop('checked', false);
                        $("#<%= ManagementNoneCheckBox.ClientID%>").prop('checked', true);
                    }
                    else {
                        $("#<%= ManagementNoneCheckBox.ClientID%>").prop('checked', false);
                    }

                }    //added by Ferdowsi
                saveManagement();   //added by Ferdowsi
            });
            //$('.management-additional-info').on('focusout', function () {
            //    var managementId = $(this).attr('data-managementid');
            //    var additionalInfoText = $(this).val();
            //    var checked = (additionalInfoText != '');

            //    saveManagement(managementId, 0, checked, additionalInfoText);
            //});

            //$('.management-parent input').on('change', function () {
            //    var childControl = $(this).closest('td').find('.management-child');
            //    if (childControl.length > 0) {
            //        if ($(this).is(':checked')) {
            //            $(childControl).show();
            //        }
            //        else {
            //            $(childControl).hide();
            //        }
            //    }

            //    //auto save
            //    var id = $(this).closest('td').find('.management-parent').attr('data-managementid');
            //    var checked = $(this).is(':checked');

            //    saveManagement(id, 0, checked, '');
            //});

            //$('.management-other-entry-toggle input').on('change', function () {
            //    checkAndNotifyTextEntry(this, 'management');
            //});
        });

        function ToggleBoxChanged(event, TD) {

            Toggle(($(event.target).is(':checked')), TD); <%-- Edited by Ferdowsi, event added--%>
            if (TD == 'ManagementOtherTD') {
                if (!$('#<%=ManagementOtherCheckBox.ClientID%>').is(':checked')) {
                    $('#<%=ManagementOtherTextBox.ClientID%>').val('');
                }
            }
            saveManagement();
        }
        function ClearControls(parentCtrlId, noneChkBoxId) {
            $("#" + parentCtrlId + " input:checkbox:checked").not("[id*='" + noneChkBoxId + "']").removeAttr("checked");
            $("#" + parentCtrlId + " input:radio:checked").removeAttr("checked");
            $("#" + parentCtrlId + " input:text").val('');
            $("#" + parentCtrlId + " textarea").val('');
        }

        function childManagement_changed(sender, args) {
            var selectedValue = args.get_item().get_value();
            var managementId = sender.get_attributes().getAttribute('data-managementid');
            saveManagement(managementId, selectedValue, true, '');
        }

        function saveManagement() {
            var obj = {};
            obj.SaveDefault = saveDefault  /*edited by ferdowsi*/
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.ManagementNone = $('#<%=ManagementNoneCheckBox.ClientID%>').is(':checked');
            obj.PulseOximetry = $('#<%=PulseOximetryCheckBox.ClientID%>').is(':checked');
            obj.IVAccess = $('#<%=IVAccessCheckBox.ClientID%>').is(':checked');
            obj.IVAntibiotics = $('#<%=IVAntibioticsCheckBox.ClientID%>').is(':checked');
            obj.Oxygenation = $('#<%=OxygenationCheckBox.ClientID%>').is(':checked');
            obj.OxygenationMethod = ($('#<%=OxygenationMethodRadioButtonList.ClientID%> input:checked').length > 0) ? parseInt($('#<%=OxygenationMethodRadioButtonList.ClientID%> input:checked').val()) : 0;
            obj.OxygenationFlowRate = parseFloat($('#<%=OxygenationFlowRateTextBox.ClientID%>').val()) || 0;
            obj.ContinuousECG = $('#<%=ContinuousECGCheckBox.ClientID%>').is(':checked');
            obj.BP = $('#<%=BPCheckBox.ClientID%>').is(':checked');
            obj.BPSystolic = parseFloat($('#<%=BPSysTextBox.ClientID%>').val()) || 0;
            obj.BPDiastolic = parseFloat($('#<%=BPDiaTextBox.ClientID%>').val()) || 0;
            obj.ManagementOther = ($('#<%=ManagementOtherTextBox.ClientID%>').val() != '') ? $('#<%=ManagementOtherCheckBox.ClientID%>').is(':checked') : false; //we only want to record other being ticket if there's been text entered, otherwise the summary will look odd until text filled in 
            obj.ManagementOtherText = ($('#<%=ManagementOtherTextBox.ClientID%>').val() != '') ? $('#<%=ManagementOtherTextBox.ClientID%>').val() : '';
           
            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveManagement",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    autoSaveSuccess = true;
                    setRehideSummary();
                    if (saveDefault) {   //added by Ferdowsi
                        window.radalert('Record saved successfully', 275, 100, "Save Successful");
                        saveDefault = false;
                    } //added by Ferdowsi
                  
                    $find('<%=DefaultRadButton.ClientID%>').set_enabled(true);
                    
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

        function SaveDefault(sender, args) {
            saveDefault = true
            $find('<%=DefaultRadButton.ClientID%>').set_enabled(false);
           saveManagement()
       }




    </script>
</telerik:RadScriptBlock>


<asp:UpdatePanel ID="UpdatePanel1" runat="server"> <%-- Added by Ferdowsi, UpdatePanel added--%>
    <ContentTemplate>
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
            Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="350" Height="200" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />

        <div class="control-content">
            <table border="0" id="ManagementTable" runat="server" cellspacing="0" cellpadding="0" class="checkboxesTable " width="100%">
                <%-- Added by Ferdowsi, width added--%>
                <tr>
                    <td colspan="3">
                        <asp:CheckBox ID="ManagementNoneCheckBox" runat="server" Text="None" />
                    </td>
                </tr>
                <tr style="height: 15px;">
                    <td colspan="3"></td>
                </tr>
                <tr>
                    <td style="width: 50%; height: 23px;">
                        <asp:CheckBox ID="PulseOximetryCheckBox" runat="server" Text="Pulse oximetry" /></td>
                    <td style="padding-left: 20px"><%-- Added by Ferdowsi --%>
                        <asp:CheckBox ID="OxygenationCheckBox" runat="server" Text="Oxygenation"
                            onchange="ToggleBoxChanged(event,'OxygenationMethodTD')" />
                        <%-- Edited by Ferdowsi, event added--%>
                    </td>
                    <td id="OxygenationMethodTD" runat="server" style="vertical-align: bottom;" tabindex="-1" clientidmode="Static">
                        <asp:RadioButtonList ID="OxygenationMethodRadioButtonList" runat="server" CssClass="man-rbl"
                            CellSpacing="1" CellPadding="1" RepeatDirection="Horizontal" RepeatLayout="Flow">
                            <asp:ListItem Value="1" Text="Cannulae"></asp:ListItem>
                            <asp:ListItem Value="2" Text="Mask"></asp:ListItem>
                        </asp:RadioButtonList>
                        &nbsp;&nbsp;&nbsp;
                        <%--<telerik:RadTextBox ID="OxygenationFlowRateTextBox" runat="server" Skin="Windows7" Width="50" CssClass="man-tb" />--%>
                        <telerik:RadNumericTextBox ID="OxygenationFlowRateTextBox" runat="server" CssClass="man-tb"
                            IncrementSettings-InterceptMouseWheel="false"
                            IncrementSettings-Step="1"
                            Width="50px"
                            MinValue="0"
                            Culture="en-GB" DbValueFactor="1" LabelWidth="20px">
                            <NumberFormat DecimalDigits="0" />
                        </telerik:RadNumericTextBox>
                        l/min
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:CheckBox ID="IVAccessCheckBox" runat="server" Text="IV access" /></td>
                    <td colspan="2" style="padding-left: 20px">
                        <asp:CheckBox ID="ContinuousECGCheckBox" runat="server" Text="Continuous ECG" /></td>
                </tr>
                <tr>
                    <td>
                        <asp:CheckBox ID="IVAntibioticsCheckBox" runat="server" Text="IV antibiotics" /></td>
                    <td style="height: 23px; padding-left: 20px" colspan="2">
                        <asp:CheckBox ID="BPCheckBox" runat="server" Text="Blood pressure" onchange="ToggleBoxChanged(event, 'BPDetailsDiv');" />
                        <%-- Edited by Ferdowsi, event added--%>
                        <div id="BPDetailsDiv" runat="server" style="color: black; margin-left: 20px;" tabindex="-1" clientidmode="Static">
                            <%-- removed by Ferdowsi--%>
                            <table border="0" style="color: black; margin-left: 20px;">

                                <tr>
                                    <td>Systolic</td>
                                    <td style="vertical-align: bottom;">
                                        <%--<telerik:RadTextBox ID="BPSysTextBox" runat="server" Skin="Windows7" Width="50" CssClass="man-tb" />--%>
                                        <telerik:RadNumericTextBox ID="BPSysTextBox" runat="server" CssClass="man-tb"
                                            IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="1"
                                            Width="50px"
                                            MinValue="0"
                                            Culture="en-GB" DbValueFactor="1" LabelWidth="20px">
                                            <NumberFormat DecimalDigits="0" />
                                        </telerik:RadNumericTextBox>
                                        &nbsp;mm</td>
                                </tr>
                                <tr>
                                    <td>Diastolic</td>
                                    <td style="vertical-align: bottom;">
                                        <%--<telerik:RadTextBox ID="BPDiaTextBox" runat="server" Skin="Windows7" Width="50" CssClass="man-tb" />--%>
                                        <telerik:RadNumericTextBox ID="BPDiaTextBox" runat="server" CssClass="man-tb"
                                            IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="1"
                                            Width="50px"
                                            MinValue="0"
                                            Culture="en-GB" DbValueFactor="1" LabelWidth="20px">
                                            <NumberFormat DecimalDigits="0" />
                                        </telerik:RadNumericTextBox>
                                        &nbsp;mm</td>
                                </tr>
                            </table>
                        </div>
                    </td>

                </tr>
                <tr>
                    <td colspan="3" style="height: 50px; vertical-align: top;">
                        <asp:CheckBox ID="ManagementOtherCheckBox" runat="server" Text="Other"
                            onchange="ToggleBoxChanged(event, 'ManagementOtherTextBox');" />
                        <telerik:RadTextBox ID="ManagementOtherTextBox" runat="server" Skin="Windows7" MaxLength="1000" Width="320" Height="45" TextMode="MultiLine" CssClass="man-tb" />

                    </td>
                </tr>
                <tr>
                    <td></td>
                </tr>
            </table>
            <div>
                <telerik:RadButton ID="DefaultRadButton" runat="server" Text="Save as default" Skin="Windows7" AutoPostBack="false" OnClientClicked="SaveDefault" />


            </div>
        </div>
    </ContentTemplate> <%-- added by Ferdowsi--%>
</asp:UpdatePanel>
