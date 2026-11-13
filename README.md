# DWH_PostgreSQL
_project is in the state of uploading_

DataWareHouse project for OFFLINE AND ONLINE GROCERY SALES AND DELIVERY with medalion architecture from data modeling to PowerBI dashboards.

[Initial dataset ](https://www.kaggle.com/datasets/andrexibiza/grocery-sales-dataset) 
is simulated. It was united, modified and augmented to be representative of real business processes

[Documentation](https://github.com/SiriusJoker/DWH_PostgreSQL/blob/main/documentation.md) describes datasets, business sides of dataset, data models, DWH building process

[bronze](https://github.com/SiriusJoker/DWH_PostgreSQL/tree/main/bronze), [silver](https://github.com/SiriusJoker/DWH_PostgreSQL/tree/main/silver), [gold](https://github.com/SiriusJoker/DWH_PostgreSQL/tree/main/gold) describes creating bronze, silver and gold layers

[cleansing layer](https://github.com/SiriusJoker/DWH_PostgreSQL/tree/main/cleansing%20layer) consists of scripts for creating a role that manages data movement through the pipeline, logging the process, and [executing routines for populating layers, creating partitions, and implementing a rolling windows](https://github.com/SiriusJoker/DWH_PostgreSQL/tree/main/cleansing%20layer/Routines/BL_DM).
