<#setting locale=locale>

<#assign layoutLocalService = serviceLocator.findService("com.liferay.portal.kernel.service.LayoutLocalService")>

<#assign assetEntryLocalService = serviceLocator.findService("com.liferay.asset.kernel.service.AssetEntryLocalService")>
<#assign assetVocabularyLocalService = serviceLocator.findService("com.liferay.asset.kernel.service.AssetVocabularyLocalService")>
<#assign dlFileEntryLocalService = serviceLocator.findService("com.liferay.document.library.kernel.service.DLFileEntryLocalService")>

<#assign staffVocabularyName = "Enhet" />
<#assign categoryCssPrefix = "category" />

<#assign page = themeDisplay.getLayout() />
<#assign group_id = page.getGroupId() />
<#assign company_id = themeDisplay.getCompanyId() />

<#assign uniqueStaffCategoryIds = [] />
<#assign uniqueStaffCategories = [] />

<#attempt>
  <#assign staffVocabulary = assetVocabularyLocalService.getGroupVocabulary(group_id, staffVocabularyName)! />
<#recover>
</#attempt>

<#if staffVocabulary?has_content>
  <#list entries as entry>
    <#list entry.getCategories() as category >
      <#if category.getVocabularyId() == staffVocabulary.getVocabularyId()>
        <#assign categoryId = category.getCategoryId() />
        <#if (uniqueStaffCategoryIds?seq_contains(categoryId)) == false >
          <#assign uniqueStaffCategoryIds = uniqueStaffCategoryIds + [ categoryId ] />
          <#assign uniqueStaffCategories = uniqueStaffCategories + [ category ] />
        </#if>
      </#if>
    </#list>
  </#list>
</#if>

<#if uniqueStaffCategories?has_content>
  <#if uniqueStaffCategories?size gt 1>
    <div class="select-filter js-select-filter" data-filterctn="${renderResponse.getNamespace()}staffContainer" data-filteritemselector="person">
      <label for="${renderResponse.getNamespace()}selecteCategory">
        ${languageUtil.get(locale, "show")}:
      </label>
      <select id="${renderResponse.getNamespace()}selecteCategory" name="${renderResponse.getNamespace()}selecteCategory">
        <option value="0">${languageUtil.get(locale, "all")}</option>
        <#list uniqueStaffCategories as category>
          <#assign categoryName = category.getTitle(locale) />
          <#assign categoryClassName = cssClassNameFromString(categoryName, categoryCssPrefix) />
          <option value="${categoryClassName}">${categoryName}</option>
          </li>
        </#list>
      <select>
    </div>
  </#if>
</#if>

<#-- For testing -->
<#--
<#assign entries = entries + entries + entries + entries />
-->

<div class="staff" id="${renderResponse.getNamespace()}staffContainer">

  <#if entries?has_content>
      <#list entries as entry>

        <#assign docXml = saxReaderUtil.read(entry.getAssetRenderer().getArticle().getContentByLocale(locale)) />

        <#assign firstName = docXml.valueOf("//dynamic-element[@name='firstName']/dynamic-content/text()") />
        <#assign lastName = docXml.valueOf("//dynamic-element[@name='lastName']/dynamic-content/text()") />
        <#assign jobTitle = docXml.valueOf("//dynamic-element[@name='jobTitle']/dynamic-content/text()") />
        <#assign email = docXml.valueOf("//dynamic-element[@name='email']/dynamic-content/text()") />
        <#assign phone = docXml.valueOf("//dynamic-element[@name='phone']/dynamic-content/text()") />
        <#assign linkUrl = docXml.valueOf("//dynamic-element[@name='link']/dynamic-content/text()") />
        <#assign linkLabel = docXml.valueOf("//dynamic-element[@name='link']/dynamic-element[@name='linkLabel']/dynamic-content/text()") />
        <#assign imageFieldValue = docXml.valueOf("//dynamic-element[@name='image']/dynamic-content/text()") />

        <#assign imageUrl = getArticleDLEntryUrl(imageFieldValue) />

        <#if !(imageUrl?has_content)>
          <#assign imageUrl = themeDisplay.getPathThemeImages() + "/theme/staff/no-img.png" />
        </#if>

        <#assign categoryClassNames = "" />
        <#list entry.getCategories() as category >
          <#assign categoryClassName = cssClassNameFromString(category.getTitle(locale), categoryCssPrefix) />
          <#assign categoryClassNames = categoryClassNames + " " + categoryClassName />
        </#list>

        <div class="block display-option-50 kivpersonblock">

          <div class="person ${categoryClassNames} contact-info-wrap">
            <div>
              <div>
                <div>
                  <h2>${firstName} ${lastName}</h2>


                  <#if jobTitle?has_content>
                    <div>
                      <span>${jobTitle}</span>
                    </div>
                  </#if>
                </div>
              </div>
            </div>

            <div class="block-row">
              <div class="media">
                <i class="icon icon-phone"></i>

                <div class="media-body">
                  <b>Telefonnummer</b>
                  <div>
                    <span>Mobil: </span><a href="tel:${phone}" title="Mobil number">${phone}</a>
                  </div>
                </div>
              </div>
            </div>

            <div class="block-row">
              <div class="media">
                <i class="icon icon-envelope"></i>

                <div>
                  <b>E-post</b>
                  <div>
                    <a href="mailto:${email}">
                      ${email}
                    </a>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

      </#list>
  </#if>

</div>

<#--
Function that returns the download url for a DLFileEntry in an article
Params: xmlValue = the xml-value of the DLFileEntry node in the article XML.
If structure field for the DLFileEntry is called image, the xmlValue can be retrieved by
<#assign xmlValue = docXml.valueOf("//dynamic-element[@name='image']/dynamic-content/text()") />
Returns: the download-url of the DLFileEntry

Requires the following services located in ADT:
<#assign assetEntryLocalService = serviceLocator.findService("com.liferay.asset.kernel.service.AssetEntryLocalService")>
<#assign dlFileEntryLocalService = serviceLocator.findService("com.liferay.document.library.kernel.service.DLFileEntryLocalService")>
-->
<#function getArticleDLEntryUrl xmlValue>
  <#local docUrl = "" />

  <#if xmlValue?has_content>
    <#local jsonObject = xmlValue?eval />

    <#local entryUuid = jsonObject.uuid />
    <#local entryGroupId = getterUtil.getLong(jsonObject.groupId) />

    <#local dlFileEntry = dlFileEntryLocalService.getDLFileEntryByUuidAndGroupId(entryUuid, entryGroupId) />

    <#local assetEntry = assetEntryLocalService.getEntry("com.liferay.document.library.kernel.model.DLFileEntry", dlFileEntry.fileEntryId) />
    <#local assetRenderer = assetEntry.assetRenderer />

    <#local docUrl = assetRenderer.getURLDownload(themeDisplay) />
  </#if>
  <#return docUrl />
</#function>

<#function cssClassNameFromString myString prefix>
  <#local myStringReplaced = prefix + "-" + myString?lower_case?replace(" ", "-")?replace("[^a-z-]", "", "r") />
  <#return myStringReplaced />
</#function>
