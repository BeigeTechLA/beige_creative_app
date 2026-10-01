**File Manager Folder Structure**

*Product / Engineering Specification*

This document explains the expected folder structure for the mobile app file manager. There are two distinct folder structure flows, depending on the type of job:

* Common Event folder structure

* Normal Shoot folder structure

# **1\. Common Event Folder Structure**

For common events, there are no separate Pre Production and Post Production folders. In this flow, the CP (Creative Partner) directly creates their own folders inside the main event folder and uploads files inside those folders.

## **Expected Structure**

| Main Event Folder └── CP-created folders     └── Uploaded files |
| :---- |

&nbsp;

## **Expected Mobile App Behavior**

* Show the main event folder.

* Allow CPs to create folders directly under the main event folder.

* Allow CPs to upload files inside their created folders.

* Do not show fixed Pre Production or Post Production folders for common events.

# **2\. Normal Shoot Folder Structure**

For normal shoots, a fixed folder structure is used.

## **Expected Structure**

| Main Shoot Folder ├── Pre Production └── Post Production     ├── Raw Footages     ├── Edits     │   ├── Revision     │   └── Selected for Edits     └── Final Deliverables |
| :---- |

&nbsp;

## **Expected Mobile App Behavior**

* Show the main shoot folder.

* Inside the main shoot folder, show Pre Production and Post Production.

* CP should not be able to upload files inside the Pre Production folder.

* Inside Post Production, show these three folders:

  * Raw Footages

  * Edits

  * Final Deliverables

* Inside Edits, show these two folders:

  * Revision

  * Selected for Edits

# **Upload Permission Summary**

The table below summarizes upload permissions for CPs across both flows.

| Folder | Upload Allowed for CP? |
| :---- | :---: |
| Common Event – Main Event Folder | **—** |
| └ CP-created folders | **Allowed** |
| Normal Shoot – Main Shoot Folder | **—** |
| ├ Pre Production | **Disabled** |
| └ Post Production | **—** |
| ├ Raw Footages | **Allowed** |
| ├ Edits → Revision | **Allowed** |
| ├ Edits → Selected for Edits | **Allowed** |
| └ Final Deliverables | **Allowed** |

# **Final Notes**

* The mobile app should identify whether the current file manager context is a common event or a normal shoot.

* For common events, CPs manage their own folders directly under the main event folder.

* For normal shoots, the app should use the fixed Pre Production and Post Production folder structure, with upload disabled for CPs in Pre Production.