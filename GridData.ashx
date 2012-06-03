<%@ WebHandler Language="C#" Class="GridData" %>

using System;
using System.Web;
using System.Xml.Linq;
using System.Linq;

public class GridData : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        /*
         Querystring Keys:
            _search - Search text? - "false"
            nd - ?? - "1338194266951"
            rows - # of rows requested by the client - 5
            page - page requested by client - 1
            sidx - sort column name - "invid"
            sord - sort order - asc / desc
        */

        int numberOfRowsPerPage = int.Parse(context.Request.QueryString["rows"]);
        int page = int.Parse(context.Request.QueryString["page"]);

        // Pretend like we're making a call to our reporting layer to get our data back
        XDocument xDocData = XDocument.Load(context.Server.MapPath("Data/JQGrid_SampleData.xml"));
        var collStronglyTypedList = from XElement rowElement 
                                    in xDocData.Elements(XName.Get("DataRows"))
                                        .First()
                                        .Elements()
                select new
                    {
                        Id = int.Parse(rowElement.Attributes(XName.Get("id")).First().Value)
                        ,
                        InvoiceId = rowElement.Attributes(XName.Get("InvoiceId")).First().Value
                        ,
                        InvoiceDate = DateTime.Parse(rowElement.Attributes(XName.Get("InvoiceDate")).First().Value)
                        ,
                        Amount = decimal.Parse(rowElement.Attributes(XName.Get("Amount")).First().Value)
                        ,
                        Tax = decimal.Parse(rowElement.Attributes(XName.Get("Tax")).First().Value)
                        ,
                        Total = decimal.Parse(rowElement.Attributes(XName.Get("Total")).First().Value)
                        ,
                        Notes = rowElement.Attributes(XName.Get("Notes")).First().Value
                    };

        // now apply filtering and paging logic and get any other "return variables"
        var listToReturnFilteredAndPaged = collStronglyTypedList.Skip(numberOfRowsPerPage * (page - 1)).Take(numberOfRowsPerPage);
        int totalPages = (int) Math.Ceiling(
                                                (double)collStronglyTypedList.Count()
                                                    / (double)numberOfRowsPerPage
                                            );
        
        
        // Construct return xml based on what JQGrid wants
        XElement xElementToReturn = new XElement("rows");
        xElementToReturn.Add(new XElement("page", page));
        xElementToReturn.Add(new XElement("total", totalPages));
        xElementToReturn.Add(new XElement("records", collStronglyTypedList.Count()));

        foreach (var invoiceItem in listToReturnFilteredAndPaged)
        {
            XElement rowElement = new XElement("row");
            rowElement.SetAttributeValue("id", invoiceItem.Id);
            rowElement.Add(new XElement("cell", invoiceItem.InvoiceId));
            rowElement.Add(new XElement("cell", invoiceItem.InvoiceDate));
            rowElement.Add(new XElement("cell", invoiceItem.Amount));
            rowElement.Add(new XElement("cell", invoiceItem.Tax));
            rowElement.Add(new XElement("cell", invoiceItem.Total));
            rowElement.Add(new XElement("cell", context.Server.HtmlEncode(invoiceItem.Notes) ) );
            //rowElement.Add(new XElement("cell", "<![CDATA[" + invoiceItem.Notes + "]]>"));

            xElementToReturn.Add(rowElement);
        }
        
        context.Response.ContentType = "text/xml";
        context.Response.Write(xElementToReturn.ToString());

    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }























}