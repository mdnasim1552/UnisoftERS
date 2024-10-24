<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="UrineDipstickCytology.ascx.vb" Inherits="UnisoftERS.UrineDipstickCytology" %>

<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        
        function childUrineDipstickCytology_dropdown_changed(sender, args) {
        
            var childId = args.get_item().get_value();
            var UrineDipstickCytologyId = sender.get_attributes().getAttribute('data-UrineDipstickCytologyId');
            SaveUrineDipstickCytology(UrineDipstickCytologyId, true, '', childId,null);
        }

        function OnSendDateSelected(sender,args) {
            var datesent = sender.get_selectedDate();
           
            var dateInput = sender.get_dateInput();
           
            var formattedDate = dateInput.get_dateFormatInfo().FormatDate(datesent, dateInput.get_displayDateFormat());
           
            var id = sender.get_element().id.replace("_dateInput", "") + "_wrapper";
            var wrapper = $get(id)
            var UrineDipstickCytologyId = wrapper.getAttribute('data-UrineDipstickCytologyId');
            SaveUrineDipstickCytology(UrineDipstickCytologyId, true, '', 0,formattedDate);
            
        }

        function SaveUrineDipstickCytology(previousDiseaseId, checked, additionalInfo, childId,formattedDate) {
            var obj = {};
            obj.procedureId = parseInt("<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID) %>");
            obj.previousDiseaseId = previousDiseaseId;
            obj.checked = checked;
            obj.additionalInfo = additionalInfo;
            obj.childId = childId;
           
            obj.dateSent = formattedDate;
            
            
            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/saveUrineDipstickCytology",
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
        };

        $(document).ready(function () {
            $(".UrineDipstickCytology-parent input").on('change', function () {
                var id = $(this).closest('td').find('.UrineDipstickCytology-parent').attr('data-UrineDipstickCytologyId');

                var checked = $(this).is(':checked');
               
              
                if (checked) {

                    $(this).closest("tr").find("[data-ChildUrineDipstickCytologyId='"+ id+"']").show();
                    var childDropdown = $(this).closest("tr").find("[data-UrineDipstickCytologyId='" + id + "']");
                    var childId = $find($(childDropdown)[1].id).get_value()
                   SaveUrineDipstickCytology(id, checked, '', childId,null);
                  
                }
                else {
                    $(this).closest("tr").find("[data-ChildUrineDipstickCytologyId='" + id + "']").hide();
                     SaveUrineDipstickCytology(id, checked, '', 0,null);
                }
            });

            $(".UrineDipstickCytology-child-chkbox input").on('change', function () {
                var parenUrineDipstickCytologyId = $(this).closest('td').find('.UrineDipstickCytology-parent').attr('data-UrineDipstickCytologyId');
                let childUrineDipstickCytologyId = 0;
                

               if ($(this).is(':checked'))
                    childUrineDipstickCytologyId = $(this).closest('td').find('.UrineDipstickCytology-child-chkbox').attr('data-UrineDipstickCytologyId');

                 SaveUrineDipstickCytology(parenUrineDipstickCytologyId, true, '', childUrineDipstickCytologyId,null);
            })
        });

    </script>
</telerik:RadScriptBlock>

<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />


<div class="control-section-header abnorHeader" style="margin-top:28px">Urine Dipstick And Cytology</div>
<div class="control-content">
    <asp:Repeater ID="rptSection" runat="server">
        
        <ItemTemplate>
                <div class="control-sub-header" style="margin-left: 0px; margin-bottom: 5px;">
                    <asp:Label ID="SectionNameLabel" runat="server" Text='<%#Eval("SectionName") %>' />

                </div>
                <asp:Repeater ID="rptUrineDipstick" runat="server">
                    <HeaderTemplate>
                        <table>
                             <tr>
                    </HeaderTemplate>
                    <ItemTemplate>
                         
                         <%# IIf((Container.ItemIndex) Mod 2 = 0, "</tr><tr>", "")%>
                       
                            <td>
                                <asp:CheckBox ID="PreviousDiseaseCheckbox" runat="server" data-UrineDipstickCytologyId='<%# Eval("UniqueId") %>' Text='<%# Eval("Description") %>' CssClass="UrineDipstickCytology-parent" />

                            </td>
                             <td>
                         <telerik:RadComboBox ID="UrineDipstickCytologyDropdown" style="display:none" data-ChildUrineDipstickCytologyId='<%# Eval("UniqueId") %>' data-UrineDipstickCytologyId='<%# Eval("UniqueId") %>'  runat="server" Skin="Metro" Width="200" CssClass="followup-text-input" />
                    
                    </td>
                       
                    </ItemTemplate>
                    <FooterTemplate>
                         </tr>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>
                <asp:Repeater ID="rptUrineCytology" runat="server">
                   
                    <HeaderTemplate>
                        <table class="IndicationsTable MinTableWidth300" cellpadding="0" cellspacing="0"> 
                    </HeaderTemplate>
                    <ItemTemplate>
                       <tr>
                            <td>
                                 <asp:Label Text='<%# Eval("Description") %>' runat="server"></asp:Label>
                            </td>
                           
 
                            <td>
                                 <%--<input id="UrineCytologyDateSent" class="urineDate" data-UrineDipstickCytologyId='<%# Eval("UniqueId") %>' visible='<%# IIf(Eval("ChildControlType").ToString() = "date", True, False)%>' runat="server" type="text" value="dd/mm/yyyy" />--%>
                               
                                <%--   Problemtic code for design breaking start --%>
                                <telerik:RadDatePicker ID="UrineCytologyDateSent" runat="server" data-UrineDipstickCytologyId='<%# Eval("UniqueId") %>' Visible='<%# IIf(Eval("ChildControlType").ToString() = "date", True, False)%>'>
                                    <ClientEvents OnDateSelected="OnSendDateSelected" /><DateInput DateFormat="dd/MM/yyyy"> </DateInput>

                                </telerik:RadDatePicker> 

                               <%--   End --%>

                                 <telerik:RadComboBox ID="UrineDipstickCytologydropdown"  data-ChildUrineDipstickCytologyId='<%# Eval("UniqueId") %>' data-UrineDipstickCytologyId='<%# Eval("UniqueId") %>' Visible='<%# IIf(Eval("ChildControlType").ToString() = "dropdown", True, False)%>'  runat="server" Skin="Metro" Width="200" CssClass="followup-text-input" />
                            </td>
                       </tr>
                    </ItemTemplate>
                    <FooterTemplate>                   
                        </table>
                    </FooterTemplate>
                </asp:Repeater>
          
        </ItemTemplate>
       
      
    </asp:Repeater>

<%--<script type="text/javascript">
    $(document).ready(function () {
        debugger;
        $(".urineDate").datepicker({ dateFormat: "dd/mm/yy" }).val();
    });
</script>--%>
</div>