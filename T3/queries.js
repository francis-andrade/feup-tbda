/*
----------------------------------
--a)------------------------------
----------------------------------
*/
db.districts.aggregate([
			{$unwind: "$municipalities"},
			{$unwind: "$municipalities.facilities"}, 
			{$match: {"municipalities.facilities.roomtype": /touros/, "municipalities.facilities.activities": "teatro"}},
            {$project: {_id: 0,"Facility ID": "$municipalities.facilities.id", "Facility Name": "$municipalities.facilities.name", "Room Type Description": "$municipalities.facilities.roomtype", "Activity": "teatro"}},
			{$sort: {"Facility ID":1}}
			]);
/*
Result:
[
    {
        "Facility ID" : 916,
        "Facility Name" : "COLISEU JOSÉ RONDÃO DE ALMEIDA-EX PRAÇA DE TOIROS",
        "Room Type Description" : "Praça de touros multiusos",
        "Activity" : "teatro"
    },
    {
        "Facility ID" : 940,
        "Facility Name" : "ARENA DE ÉVORA - EX PRAÇA DE TOIROS",
        "Room Type Description" : "Praça de touros multiusos",
        "Activity" : "teatro"
    },
    {
        "Facility ID" : 957,
        "Facility Name" : "COLISEU DE REDONDO - EX PRAÇA DE TOIROS",
        "Room Type Description" : "Praça de touros multiusos",
        "Activity" : "teatro"
    }
]
*/
/*
----------------------------------
--b)------------------------------
----------------------------------
*/
 db.districts.aggregate([
			{$unwind: "$municipalities"},
			{$unwind: "$municipalities.facilities"}, 
			{$match: {"municipalities.facilities.roomtype": /touros/}},
            {$group: {_id: "$municipalities.region.designation", "NoFacilities": {$sum: 1}}},
            {$project: {"_id":0, "Region": "$_id", "NoFacilities": "$NoFacilities"}},
            {$sort: {"Region": 1}}
			]);
/*
Result:
[
    {
        "Region" : "Alentejo",
        "NoFacilities" : 43.0
    },
    {
        "Region" : "Algarve",
        "NoFacilities" : 1.0
    },
    {
        "Region" : "Centro",
        "NoFacilities" : 11.0
    },
    {
        "Region" : "Lisboa",
        "NoFacilities" : 6.0
    },
    {
        "Region" : "Norte",
        "NoFacilities" : 3.0
    }
]
*/
/*
----------------------------------
--c)------------------------------
----------------------------------
*/
 db.districts.aggregate([
			{$project: {"_id": 0}},
			{$unwind: "$municipalities"},
			{$match: {"municipalities.facilities.activities": {$nin: ["cinema"]}}},
            {$count: "NoMunicipalities"}
			]);
/*
Result:
{
    "NoMunicipalities" : 100
}
*/
/*
----------------------------------
--d)------------------------------
----------------------------------
*/
 db.districts.aggregate([
                        {$unwind: "$municipalities"},
                        {$unwind: "$municipalities.facilities"},
                        {$unwind: "$municipalities.facilities.activities"},
						{$group: {_id: {"activity": "$municipalities.facilities.activities", "municipality": "$municipalities.designation"}, count: {$sum: 1}}},
                        {$sort: {"count": -1}},
                        {$group: {_id: "$_id.activity", 
                            "municipalities":{
                                $push: {"municipality": "$_id.municipality", "count": "$count"}
                            }
                        }},
                        {$project: {
                           "_id": 0,
                           "Activity": "$_id" ,
                           "Municipality": {$arrayElemAt: ["$municipalities.municipality", 0]},
                           "NoFacilities": {$arrayElemAt: ["$municipalities.count", 0]}
                        }},
                        {$sort: {"Activity": 1}}
			]);
/*
Result:
[
    {
        "Activity" : "cinema",
        "Municipality" : "Lisboa",
        "NoFacilities" : 96.0
    },
    {
        "Activity" : "circo",
        "Municipality" : "Lisboa",
        "NoFacilities" : 2.0
    },
    {
        "Activity" : "dança",
        "Municipality" : "Lisboa",
        "NoFacilities" : 47.0
    },
    {
        "Activity" : "música",
        "Municipality" : "Lisboa",
        "NoFacilities" : 77.0
    },
    {
        "Activity" : "tauromaquia",
        "Municipality" : "Moura",
        "NoFacilities" : 4.0
    },
    {
        "Activity" : "teatro",
        "Municipality" : "Lisboa",
        "NoFacilities" : 66.0
    }
]
*/
/*
----------------------------------
--e)------------------------------
----------------------------------
*/
 db.districts.aggregate([
                        {$match: {"municipalities.facilities": {$ne: null}}},
                        {$project: {_id:0, "Code": "$_id", "Designation": "$designation"}},
                        {$sort: {"Designation": 1}}
                        ]);
/*
Result:

[
    {
        "Code" : 11,
        "Designation" : "Lisboa"
    },
    {
        "Code" : 12,
        "Designation" : "Portalegre"
    },
    {
        "Code" : 15,
        "Designation" : "Setúbal"
    },
    {
        "Code" : 7,
        "Designation" : "Évora"
    }
]
*/