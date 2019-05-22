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
/*
------------------------------------------------------------------------------------------
--f)--------------------------------------------------------------------------------------
--For each district find the percentage of municipalities that have facilities for cinema-
------------------------------------------------------------------------------------------
*/
 db.districts.aggregate([
                        {$addFields: {"size_mun": {$size: "$municipalities"}}},
                        {$unwind: "$municipalities"},
						{$match: {"municipalities.facilities.activities": {$in: ["cinema"]}}},
                        {$group: {_id: {"designation": "$designation","size_mun": "$size_mun"}, count: {$sum: 1}}},
                        {$project: {_id:0, "Distrito": "$_id.designation","Percentage": {$divide: [{$multiply: ["$count", 100]}, "$_id.size_mun"] }}},
                        {$sort: {"Distrito": 1}}
                        ]);
/*
Result:
[
    {
        "Distrito" : "Aveiro",
        "Percentage" : 89.4736842105263
    },
    {
        "Distrito" : "Beja",
        "Percentage" : 78.5714285714286
    },
    {
        "Distrito" : "Braga",
        "Percentage" : 57.1428571428571
    },
    {
        "Distrito" : "Bragança",
        "Percentage" : 66.6666666666667
    },
    {
        "Distrito" : "Castelo Branco",
        "Percentage" : 63.6363636363636
    },
    {
        "Distrito" : "Coimbra",
        "Percentage" : 58.8235294117647
    },
    {
        "Distrito" : "Faro",
        "Percentage" : 75.0
    },
    {
        "Distrito" : "Guarda",
        "Percentage" : 85.7142857142857
    },
    {
        "Distrito" : "Leiria",
        "Percentage" : 75.0
    },
    {
        "Distrito" : "Lisboa",
        "Percentage" : 100.0
    },
    {
        "Distrito" : "Portalegre",
        "Percentage" : 73.3333333333333
    },
    {
        "Distrito" : "Porto",
        "Percentage" : 77.7777777777778
    },
    {
        "Distrito" : "Santarém",
        "Percentage" : 71.4285714285714
    },
    {
        "Distrito" : "Setúbal",
        "Percentage" : 100.0
    },
    {
        "Distrito" : "Viana do Castelo",
        "Percentage" : 60.0
    },
    {
        "Distrito" : "Vila Real",
        "Percentage" : 50.0
    },
    {
        "Distrito" : "Viseu",
        "Percentage" : 66.6666666666667
    },
    {
        "Distrito" : "Évora",
        "Percentage" : 92.8571428571429
    }
]
*/