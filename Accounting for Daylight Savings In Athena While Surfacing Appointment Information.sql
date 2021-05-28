select
case /*is Do Not Observe Daylight Savings Time turned on for all departments? */
	when exists (select 1 
		from
			tablespaceinfo
		where
			tablespaceinfo.key = 'Do Not Observe Daylight Saving Time'	
			and tablespaceinfo.value = 'ON'
			and tablespaceinfo.departmentid is null)
	then /*do not observe daylight savings time is on*/
			case /*is there a timezone offset that applies to specific departments?*/
			when exists (select 1
				from
					appointment appointment1,
					tablespaceinfo
				where 
					appointment.id = appointment1.id
					and appointment1.departmentid = tablespaceinfo.departmentid
					and tablespaceinfo.key = 'Time Zone Offset Hours'
					and tablespaceinfo.value is not null)
				then
					(select
						to_char(appointment1.starttime, 'HH24') - tablespaceinfo.value|| ':' ||to_char(appointment1.starttime, 'MI')
					from
						appointment appointment1,
						tablespaceinfo
					where
						appointment.id = appointment1.id
						and tablespaceinfo.departmentid = appointment1.departmentid
						and tablespaceinfo.key = 'Time Zone Offset Hours')
			when not exists (select 1 /*when there isn't a timezone offset for the department*/
				from
					appointment appointment1,
					tablespaceinfo
				where 
					appointment.id = appointment1.id
					and appointment1.departmentid = tablespaceinfo.departmentid
					and tablespaceinfo.key = 'Time Zone Offset Hours')
			then /* figure out whether or not there is a timezone offset for all departments or none at all*/
				case when exists (select 1 /*when a timezone offset is applied for all remaining departments*/
					from
						tablespaceinfo
					where 
						tablespaceinfo.departmentid is null
						and tablespaceinfo.key = 'Time Zone Offset Hours'
						and tablespaceinfo.value is not null)
				then
					(select
						to_char(appointment1.starttime, 'HH24') - tablespaceinfo.value|| ':' ||to_char(appointment1.starttime, 'MI')
					from
						appointment appointment1,
						tablespaceinfo
					where
						appointment.id = appointment1.id
						and tablespaceinfo.departmentid is null
						and tablespaceinfo.key = 'Time Zone Offset Hours')
				else
					to_char(appointment.starttime, 'HH24:MI')
				end
			else
				to_char(appointment.starttime, 'HH24:MI')
			end	
	when appointment.departmentid in (select /*when the department for the appointment is listed as do not observe DST*/
										tablespaceinfo.departmentid
			from
				tablespaceinfo
			where
				tablespaceinfo.key = 'Do Not Observe Daylight Saving Time'	
				and tablespaceinfo.value = 'ON'
				and tablespaceinfo.departmentid is not null)
	then
		case /* when it does apply to the department in question*/
		when exists (select 1
			from
				appointment appointment2,
				tablespaceinfo
			where
				appointment.id = appointment2.id
				and tablespaceinfo.key = 'Do Not Observe Daylight Saving Time'
				and tablespaceinfo.value is not null)
		then 
			case /*is there a timezone offset that applies to specific departments?*/
			when exists (select 1
				from
					appointment appointment1,
					tablespaceinfo
				where 
					appointment.id = appointment1.id
					and appointment1.departmentid = tablespaceinfo.departmentid
					and tablespaceinfo.key = 'Time Zone Offset Hours'
					and tablespaceinfo.value is not null)
			then
				(select
					to_char(appointment1.starttime, 'HH24') - tablespaceinfo.value|| ':' ||to_char(appointment1.starttime, 'MI')
				from
					appointment appointment1,
					tablespaceinfo
				where
					appointment.id = appointment1.id
					and tablespaceinfo.departmentid = appointment1.departmentid
					and tablespaceinfo.key = 'Time Zone Offset Hours')
			when not exists (select 1 /*when there isn't a timezone offset for the department*/
				from
					appointment appointment1,
					tablespaceinfo
				where 
					appointment.id = appointment1.id
					and appointment1.departmentid = tablespaceinfo.departmentid
					and tablespaceinfo.key = 'Time Zone Offset Hours')
			then /* figure out whether or not there is a timezone offset for all departments or none at all*/
				case when exists (select 1 /*when a timezone offset is applied for all remaining departments*/
					from
						tablespaceinfo
					where 
						tablespaceinfo.departmentid is null
						and tablespaceinfo.key = 'Time Zone Offset Hours'
						and tablespaceinfo.value is not null)
				then
					(select
						to_char(appointment1.starttime, 'HH24') - tablespaceinfo.value|| ':' ||to_char(appointment1.starttime, 'MI')
					from
						appointment appointment1,
						tablespaceinfo
					where
						appointment.id = appointment1.id
						and tablespaceinfo.departmentid is null
						and tablespaceinfo.key = 'Time Zone Offset Hours')
				else
					to_char(appointment.starttime, 'HH24:MI')
				end
			else
				to_char(appointment.starttime, 'HH24:MI')
			end
		end
	else
	/*when you have to account for daylight savings time for the department in question*/
			case /*is there a timezone offset that applies to specific departments?*/
			when exists (select 1
				from
					appointment appointment1,
					tablespaceinfo
				where 
					appointment.id = appointment1.id
					and appointment1.departmentid = tablespaceinfo.departmentid
					and tablespaceinfo.key = 'Time Zone Offset Hours'
					and tablespaceinfo.value is not null)
				then
					case /*Does the Appointment Date Fall between 2nd sunday of March and last Sunday of November*/
						when (appointment.appointmentdate >= next_day(last_day(to_date('02', 'MM')), 'Sunday') + 7 
							and appointment.appointmentdate < next_day(to_date('11', 'MM'), 'Sunday'))
						then
							(select
								to_char(appointment1.starttime, 'HH24') - 1 - tablespaceinfo.value|| ':' ||to_char(appointment1.starttime, 'MI')
							from
								appointment appointment1,
								tablespaceinfo
							where
								appointment.id = appointment1.id
								and tablespaceinfo.departmentid = appointment1.departmentid
								and tablespaceinfo.key = 'Time Zone Offset Hours')
						else
							(select
								to_char(appointment1.starttime, 'HH24') - tablespaceinfo.value|| ':' ||to_char(appointment1.starttime, 'MI')
							from
								appointment appointment1,
								tablespaceinfo
							where
								appointment.id = appointment1.id
								and tablespaceinfo.departmentid = appointment1.departmentid
								and tablespaceinfo.key = 'Time Zone Offset Hours')
						end
			when not exists (select 1 /*when there isn't a timezone offset for the department*/
				from
					appointment appointment1,
					tablespaceinfo
				where 
					appointment.id = appointment1.id
					and appointment1.departmentid = tablespaceinfo.departmentid
					and tablespaceinfo.key = 'Time Zone Offset Hours')
			then /* figure out whether or not there is a timezone offset for all departments or none at all*/
				case when exists (select 1 /*when a timezone offset is applied for all remaining departments*/
					from
						tablespaceinfo
					where 
						tablespaceinfo.departmentid is null
						and tablespaceinfo.key = 'Time Zone Offset Hours'
						and tablespaceinfo.value is not null)
				then
					case /*Does the Appointment Date Fall between 2nd sunday of March and last Sunday of November*/
						when (appointment.appointmentdate >= next_day(last_day(to_date('02', 'MM')), 'Sunday') + 7 
							and appointment.appointmentdate < next_day(to_date('11', 'MM'), 'Sunday'))
						then
							(select
								to_char(appointment.starttime, 'HH24') - 1 - tablespaceinfo.value|| ':' ||to_char(appointment.starttime, 'MI')
							from
								tablespaceinfo
							where
								tablespaceinfo.departmentid is null
								and tablespaceinfo.key = 'Time Zone Offset Hours'
								and tablespaceinfo.value is not null)
						else
							(select
								to_char(appointment.starttime, 'HH24') - tablespaceinfo.value|| ':' ||to_char(appointment.starttime, 'MI')
							from
								tablespaceinfo
							where
								tablespaceinfo.departmentid is null
								and tablespaceinfo.key = 'Time Zone Offset Hours'
								and tablespaceinfo.value is not null)
						end
				else
					case /*Does the Appointment Date Fall between 2nd sunday of March and last Sunday of November*/
							when (appointment.appointmentdate >= next_day(last_day(to_date('02', 'MM')), 'Sunday') + 7 
								and appointment.appointmentdate < next_day(to_date('11', 'MM'), 'Sunday'))
							then
								to_char(appointment.starttime, 'HH24') - 1|| ':' ||to_char(appointment.starttime, 'MI')
							else
								to_char(appointment.starttime, 'HH24:MI')
							end
				end
			else
				case /*Does the Appointment Date Fall between 2nd sunday of March and last Sunday of November*/
					when (appointment.appointmentdate >= next_day(last_day(to_date('02', 'MM')), 'Sunday') + 7 
						and appointment.appointmentdate < next_day(to_date('11', 'MM'), 'Sunday'))
					then
						to_char(appointment.starttime, 'HH24') - 1|| ':' ||to_char(appointment.starttime, 'MI')
					else
						to_char(appointment.starttime, 'HH24:MI')
					end 
			end
end "starttime",
appointment.duration,
clinicalencounter.patientid,
appointment.status,
clinicalencounter.id CLINENCID, 
clinicalencounter.status CLINENC_STATUS,
clinicalencounter.chartid,
chart.enterpriseid,
clinicalencounterdiagnosis.createdby,
clinicalencounterdiagnosis.snomedcode,
snomed.description SNOMED_DESCRIPTION,
diagnosiscode.unstrippeddiagnosiscode ICD9,
diagnosiscode.description ICD9_Description,
(select
	count(*)
	from
	orderencounterdiagnosis
	where
	clinicalencounterdiagnosis.id = orderencounterdiagnosis.clinicalencounterdiagnosisid
	group by 
	orderencounterdiagnosis.clinicalencounterdiagnosisid
	) orders	
					
from
appointment,
clinicalencounter,
chart,
clinicalencounterdiagnosis,
snomed,
clinicalencounterdxicd9,
diagnosiscode


where
appointment.id = clinicalencounter.appointmentid(+)
and clinicalencounter.chartid = chart.id(+)
and clinicalencounter.id = clinicalencounterdiagnosis.clinicalencounterid(+)
and clinicalencounterdiagnosis.snomedcode = snomed.code(+)
and clinicalencounterdiagnosis.id = clinicalencounterdxicd9.clinicalencounterdiagnosisid(+)
and clinicalencounterdxicd9.diagnosiscode = diagnosiscode.diagnosiscode(+)
and appointment.appointmentdate = trunc(sysdate) - 1 
and appointment.status not in ('o','x')			
and not exists (select 1
            from
				appointment appointment1
            where
				appointment1.id = appointment.id
				and appointment1.frozenyn = 'Y' and appointment1.requirescancellationyn = 'Y')
and clinicalencounterdiagnosis.deleted is null
and clinicalencounterdiagnosis.snomedcode > 0

order by
starttime,
clinicalencounterdiagnosis.id

