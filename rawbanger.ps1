# rawbanger
# a little utility to find-replace in the raws with 1% more smartness
# without having to write many thousands of lines of code (this should remain <1k)

using namespace System.Collections.Generic


## ---------------------------------------------------------------------------------------------- ##
## -- CONFIGURATION ----------------------------------------------------------------------------- ##

# Dwarf Fortress installation locations

$df = 'F:\SteamLibrary\steamapps\common\Dwarf Fortress'
$im = 'data\installed_mods'
$mu = 'mods\mod_upload'

# Mod source and compilation locations

$mod = "bugspilled"
$src = 'D:\vscode\proj\dwarf-fortress\bugspilled'
$out = "$df\mods"

# Conversions between entries, eg. modded equivalents of vanilla entries, get a dictionary file.
# Anything that you need to use to build the outputs of the following tasks needs its own item.

$mod_dictionaries = [ordered] @{
	ConvertNames              = @{
		tokens = 'NAME', 'CASTE_NAME', 'BABYNAME', 'CHILDNAME', 'GENERAL_BABY_NAME', 'GENERAL_CHILD_NAME'
		source = 'dictionary_name.txt'
	}
	ConvertBodyPart           = @{
		token  = 'BODY'
		source = 'dictionary_body.txt'
	}
	ConvertBodyPlan           = @{
		token  = 'BODY_DETAIL_PLAN'
		source = 'dictionary_bodyplan.txt'
	}
	ConvertBodyMaterial       = @{
		token  = 'USE_MATERIAL_TEMPLATE'
		source = 'dictionary_material.txt'
	}
	ConvertBodyTissue         = @{
		token  = 'USE_TISSUE_TEMPLATE'
		source = 'dictionary_tissue.txt'
	}
	ConvertVariation          = @{
		token  = 'APPLY_CREATURE_VARIATION'
		source = 'dictionary_variation.txt'
	}
	ConvertPath               = @{
		token  = 'LS_PALETTE_FILE'
		source = 'dictionary_path.txt'
	}
	ModdedAnimalPeople        = @{
		token      = 'BODY'
		source     = 'dictionary_animal_people.txt'
		no_reverse = $true # destructive transform
	}
	ModdedAnimalPeopleNoLegs  = @{
		token      = 'BODY'
		source     = 'dictionary_animal_people_no_legs.txt'
		no_reverse = $true
	}
	ModdedAnimalPeopleTaurian = @{
		token      = 'BODY'
		source     = 'dictionary_animal_people_taurian.txt'
		no_reverse = $true
	}
	ModdedAnimalPeopleAddNeck = @{
		token      = 'BODY'
		source     = 'dictionary_add_necks.txt'
		no_reverse = $true
	}
}

# "Converted" raws are copied first so they can be targeted by the conversion steps, below.

$raws_convert = @(
	'vanilla_creatures_graphics\graphics\graphics_creatures_dwarf.txt'
	'vanilla_creatures_graphics\graphics\graphics_creatures_elf.txt'
	'vanilla_creatures_graphics\graphics\graphics_creatures_goblin.txt'
	'vanilla_creatures_graphics\graphics\graphics_creatures_human.txt'
	'vanilla_creatures_graphics\graphics\graphics_creatures_kobold.txt'
)

# A conversion step is a set of regex substitutions from a dictionary in a source file.
# Each step can perform a lot of work. Descriptive names can prevent duplicated effort.

$conversions = [ordered] @{
	PaletteFilePath = @{
		target = 'graphics/graphics_creatures_[deghk]*.txt'
		source = 'ConvertPath' # Reuse your dictionaries as sources.
	}
}

# These files are copied after conversion is done and before the remaining edits.

$raws_copy = @(
	'vanilla_creatures_graphics\graphics\images\*\*_palettes.png'
	'vanilla_creatures_graphics\graphics\images\bone_pile.png'
	'vanilla_creatures_graphics\graphics\images\wieldables*.png'
	'vanilla_creatures_graphics\graphics\images\[deghk]*\[deghk]*_body.png'
	'vanilla_creatures_graphics\graphics\images\[deghk]*\[deghk]*_hair.png'
	'vanilla_creatures_graphics\graphics\images\[deghk]*\[deghk]*_wearables.png'

	'vanilla_items_graphics\graphics\images\upright_weapons.png'
)

# Removals can use both a dictionary (such as the conversions do) and a hardcoded list format.
# When using a dictionary, pairs of identical pattern,replacement strings are marked for removal.
# The entry and all its subtokens, not just one token or line, are removed from the target file.

$raws_remove = [ordered] @{
	# BodyNamingCollisions           = @{
	# 	source = 'dictionary_body.txt'
	# 	target = 'objects/body_default.txt'
	# 	token  = 'BODY'
	# }
}

# Unlike conversions, which should convert full files, modifications target single entries.
# You could easily make these as broad in coverage as a conversion; that much is up to you.
# But this feature is designed to help you make individual changes to individual entries.

$raws_modify = [ordered] @{
	# ReplaceJointedWings = @{
	# 	target  = 'objects/creature_next_underground.txt'
	# 	type    = 'CREATURE'
	# 	entry   = 'MAGMA_CRAB'
	# 	pattern = '\bJOIN_WINGS\b'
	# 	replace = '/WINGS'
	# }
}

# When changing vanilla files, you should prefer to combine vanilla and modded entries.
# You can remove your todos, file headers, etc. by specifying their line count.

$raws_append_mods = [ordered] @{
	# BodySkeleton      = @{
	# 	source = 'src/body_default_bugspilled.txt'
	# 	target = '/objects/body_default.txt'
	# 	remove = 3
	# }
}

# These tasks find a matching *line* and insert a file's contents before and/or afterward.
# Lines are matched one at a time (vs the full string), unlike the other processing steps.

$raws_insert = [ordered] @{
	WieldablesLeftHand  = @{
		source = 'src\graphics_creatures_wieldables_left.txt'
		target = 'graphics/graphics_creatures_*.txt'
		before = '\A\s+\[LAYER:CLOTHING_LH_HALBERD_GROWN:WIELDABLES'
	}
	WieldablesRightHand = @{
		source = 'src\graphics_creatures_wieldables_right.txt'
		target = 'graphics/graphics_creatures_*.txt'
		before = '\A\s+\[LAYER:CLOTHING_RH_HALBERD_GROWN:WIELDABLES'
	}
}

# This creates a creature variation using any source, potentially including all mod sources.
# Even if you don't use it, including a total conversion step can allow other mods to use yours.
# Maybe more importantly, a `reverse` conversion step allows other mods to *ignore* yours.

$mod_creature_variation = [ordered] @{
	AnimalPeopleAddNecks     = @{
		name   = 'CONNECT_NECK_TO_SHOULDER'
		target = 'objects/c_variation_conversions_bugspilled.txt'
		source = 'ModdedAnimalPeopleAddNeck'
	}
	ModdedAnimalPeople       = @{
		name   = 'MOD_ANIMAL_PEOPLE'
		target = 'objects/c_variation_conversions_bugspilled.txt'
		source = 'ModdedAnimalPeople'
	}
	ModdedAnimalPeopleNoLegs = @{
		name   = 'MOD_ANIMAL_PEOPLE_NO_LEGS'
		target = 'objects/c_variation_conversions_bugspilled.txt'
		source = 'ModdedAnimalPeopleNoLegs'
	}
	ConvertCreatureToMod     = @{
		name    = "CONVERT_TO_$($mod.ToUpper())"
		target  = 'objects/c_variation_conversions_bugspilled.txt'
		sources = @(
			'ConvertNames'
			'ConvertBodyPart'
			'ConvertBodyPlan'
			'ConverBodyMaterial'
			'ConverBodyTissue'
		)
	}
	ConvertCreatureFromMod   = @{
		name    = "CONVERT_FROM_$($mod.ToUpper())"
		reverse = $true
		target  = 'objects/c_variation_conversions_bugspilled.txt'
		sources = @(
			'ConvertNames'
			'ConvertBodyPart'
			'ConvertBodyPlan'
			'ConverBodyMaterial'
			'ConverBodyTissue'
		)
	}
}

# Selects create and compile patch files out of all the found, matching entries.
# Multiple selects with a single output target should combine together neatly. # todo

$mod_select = [ordered] @{
	AllCreatures          = @{
		module  = 'vanilla_creatures'
		target  = 'objects\creature_*.txt'
		output  = 'objects\creature_patch_convert_bugspilled.txt'
		object  = 'CREATURE'
		filter  = 'DOES_NOT_EXIST'
		prepend = 'src\prepend_creature_patch_convert.txt'
		process = {
			param($content, $name)
			$fixes = $null
			if ($content.Contains('[APPLY_CREATURE_VARIATION:ANIMAL_PERSON]') -or
				$content.Contains('[APPLY_CREATURE_VARIATION:ANIMAL_PERSON_LEGLESS]')) {
				$fixes = "`t[APPLY_CREATURE_VARIATION:CONNECT_NECK_TO_SHOULDER]"
				$fixes += "`n`t[APPLY_CREATURE_VARIATION:FIX_COPIED_SAPIENT]"
			}
			elseif ($content.Contains('[APPLY_CREATURE_VARIATION:GIANT]')) {
				$fixes = "`t[APPLY_CREATURE_VARIATION:FIX_COPIED_GIANT]"
			}
			if ($fixes.Length -gt 0) {
				return $fixes
			}
		}
	}
	AquaticEggLayers      = @{
		module  = 'vanilla_creatures'
		target  = 'objects\creature_*.txt'
		output  = 'objects\creature_patch_general_bugspilled.txt'
		object  = 'CREATURE'
		filter  = 'DOES_NOT_EXIST'
		process = {
			param ($content, $name)
			if ($content.Contains('[AQUATIC]') -and $content.Contains('[LAYS_EGGS]')) {
				$min, $max, $adult_at = 1, 3, 1
				if ($content -match '\[CLUTCH_SIZE:(\d+):(\d)\]') {
					$min = [int] $Matches[1]
					$max = [int] $Matches[2]
				}
				if ($content -match '\[MAXAGE:(\d+):(\d+)\]') {
					$adult_at = [int] ([math]::sqrt((1 * $Matches[1] + 4 * $Matches[2]) / 5) * 2 + 1) / 2
					$adult_at = [math]::Clamp(1, $adult_at, 20)
				}
				return "`t[APPLY_CREATURE_VARIATION:FIX_AQUATIC_EGGLAYER:$min`:$max`:$adult_at]"
			}
		}
	}
	Badgerifiction        = @{
		module  = 'vanilla_creatures'
		target  = 'objects\creature_*.txt'
		output  = 'objects\creature_patch_general_bugspilled.txt'
		object  = 'CREATURE'
		filter  = 'DOES_NOT_EXIST'
		process = {
			param ($content, $name)
			if (
				$content.Contains('[BENIGN]') -and
				-not $content.Contains('[PRONE_TO_RAGE:') -and
				-not $content.Contains('[AQUATIC]') -and # just not enough tags to go on
				-not $content.Contains('[LARGE_PREDATOR]') -and
				-not $content.Contains('[COMMON_DOMESTIC]') -and
				-not $content.Contains('[RETRACT_INTO_BP:') -and
				-not $content.Contains('[GOOD]') -and
				-not $content.Contains('[CURIOUS')
			) {
				$size = 10000
				if ($matched = $content | Select-String '\[BODY_SIZE:\d+:\d+:(\d+)]' -All) {
					$size = $matched.Matches | % { [int] ($_.Groups[1].Value) } | Measure -Max | % Maximum
				}
				if ($size -ge 200000 -or ($size -ge 3000 -and $content.Contains('venom'))) {
					if ($name -eq 'TAPIR') {
						return "`t[PRONE_TO_RAGE:1][FLEEQUICK]" # koboldification
					}
					return "`t[PRONE_TO_RAGE:1]"
				}
			}
		}
	}
	PopulationRiskFactors = @{
		module  = 'vanilla_creatures'
		target  = 'objects\creature_*.txt'
		output  = 'objects\creature_patch_general_bugspilled.txt'
		object  = 'CREATURE'
		filter  = 'DOES_NOT_EXIST'
		process = {
			param($content, $name)
			# todo: account for fecundity, not just population size
			# todo: potentially add gender to genderless creatures ; agendered MALE/FEMALE
			# todo: somehow make IMMOBILE creatures glacially slow so they can, theoretically, mate

			# Biomes support only 7 large predators. Reduce their count, as possible, unless their biome can support them.
			$large_predator = $content.Contains('[LARGE_PREDATOR]') -and -not $content.Contains('[BIOME:SUBTERRANEAN_LAVA]')
			if ($large_predator -and ($matched = $content | Select-String '\[BODY_SIZE:\d+:\d+:(\d+)]' -All)) {
				$size = $matched.Matches | % { [int] ($_.Groups[1].Value) } | Measure -Max | % Maximum
				if ($size -le 25000) {
					$less_aggressive = "`t[CV_REMOVE_TAG:LARGE_PREDATOR][PRONE_TO_RAGE:1]"
					$large_predator = $false
				}
			}

			if (-not $content.Contains(':ANIMAL_PERSON') -and
				-not $content.Contains('[INTELLIGENT]') -and
				-not $content.Contains('[FEATURE_ATTACK_GROUP]') -and
				-not $content.Contains('[COMMON_DOMESTIC]') -and
				$content.Contains('[LARGE_ROAMING]')) {
				if (
					($content.Contains('[FEMALE]') -or $content.Contains('VARIATION:GIANT]')) -and
					-not $content.Contains('[SEMIMEGABEAST]')
				) {
					$from, $to, $min, $max = 1, 1, 3, 3
					if ($content -match '\[POPULATION_NUMBER:(\d+):(\d+)]') {
						$from, $to = [int] $Matches[1], [int] $Matches[2]
						$min = [math]::Round(1.5 + 1.1 * $from)
						$max = [math]::Round(1.5 + 1.2 * $to)
					}
					if ($min + $max -lt 20) {
						if ($large_predator) {
							$min += 1
							$max += 1
						}
						if ($content -match '\[DIFFICULTY:(\d+)]') {
							$difficulty = [int] $Matches[1]
							if ($difficulty -ge 5) {
								$min = [math]::Round(($min + 1) / 2)
								$max = [math]::Round(($max + 1) / 2)
							}
						}
						if ($from -ne $min -or $to -ne $max) {
							$less_risk = "`t[POPULATION_NUMBER:$min`:$max] ---- (:$from`:$to)"
						}
					}
				}
				elseif (-not $content.Contains('[FEMALE]') -and -not $content.Contains('[VERMIN')) {
					"`t$name not evaluated for population decline." | Out-Host
				}
			}
			if (($population_adjust = ($less_aggressive, $less_risk | ? { $_ }) -join "`n").Length) {
				return $population_adjust
			}
		}
	}
	PetsThatSuckAsPets    = @{
		module  = 'vanilla_creatures'
		target  = 'objects\creature_*.txt'
		output  = 'objects\creature_patch_general_bugspilled.txt'
		object  = 'CREATURE'
		process = {
			param($content, $name)
			$min, $max = 100, 100
			if ($content -match '\[MAXAGE:(\d+):(\d+)]') {
				$min, $max = [int] $Matches[1], [int] $Matches[2]
			}
			if ($content.Contains('[PET]')) {
				if ($min -lt 5 -or $min + $max -le 12) {
					if ($content.Contains('[PET_EXOTIC]')) {
						return "`t[CV_REMOVE_TAG:PET]"
					}
					else {
						return "`t[CV_REMOVE_TAG:PET][PET_EXOTIC]"
					}
				}
			}
			elseif (($min -eq 1 -or $min + $max -lt 5) -and $content.Contains('[PET_EXOTIC]')) {
				return "`t[CV_REMOVE_TAG:PET_EXOTIC]"
			}
		}
	}
	PonderousMounts       = @{
		module  = 'vanilla_creatures'
		target  = 'objects\creature_*.txt'
		output  = 'objects\creature_patch_general_bugspilled.txt'
		object  = 'CREATURE'
		process = {
			param($content, $name)
			if ($content.Contains('[MOUNT')) {
				if ($content.Contains('[MEANDERER]') -and $content.Contains('[CAN_LEARN]')) {
					return "`t[CV_REMOVE_TAG:MOUNT][CV_REMOVE_TAG:MOUNT_EXOTIC]"
				}
				if ($matched = $content | Select-String '(\d+)\s+(?:\(.+\))?\bkph\b' -All) {
					$speed = $matched.Matches | % { [int] $_.Groups[1].Value } | Measure -Max | % Maximum
					if ($speed -lt 15) {
						return "`t[CV_REMOVE_TAG:MOUNT][CV_REMOVE_TAG:MOUNT_EXOTIC]"
					}
				}
			}
		}
	}
}

# The remaining mod source files are copied into the compilation with no further edits.
# This doesn't support any subfolders, e.g. the 'dwarf' images folder, at the moment.

$mod_info = @(
	'info.txt'
	'credits.txt'
	'license.txt'
	'src\preview.png'
	'body changes.md'

	'dictionary_*.txt'
)

$mod_objects = @(
	'src\descriptor_color_bugspilled.txt'
	'src\body_default_bugspilled.txt'
	'src\b_detail_plan_default_bugspilled.txt'
	'src\c_variation_default_bugspilled.txt'
	'src\entity_default_patch_bugspilled.txt'
	'src\inorganic_metal_patch_bugspilled.txt'
	'src\language_patch_words_bugspilled.txt'
	'src\material_template_default_bugspilled.txt'
	'src\tissue_template_default_bugspilled.txt'

	'src\creature_*_bugspilled.txt'
	'src\item_*_bugspilled.txt'
	'src\reaction_*_bugspilled.txt'
)

$mod_graphics = @(
	'src\graphics_*_bugspilled.txt'
	'src\tile_page_*_bugspilled.txt'
)

$mod_images = @(
	'src\*_bugspilled.png'
)

$mod_sounds = @(
	# place each sound file on a line
)


## ---------------------------------------------------------------------------------------------- ##
## -- FUNCTIONS --------------------------------------------------------------------------------- ##

class CvConvertTagComparer : System.Collections.Generic.IComparer[pscustomobject] {
	[int] Compare([pscustomobject] $x, [pscustomobject] $y) {
		$x_to_y = $x.replacement.Contains($y.value)
		$y_to_x = $y.replacement.Contains($x.value)

		if ($x_to_y -and $y_to_x) {
			Write-Host "CvConvertTagComparer cannot order cyclic replacements:"
			[pscustomobject] $x, [pscustomobject] $y | Format-Table | Out-Host
			throw "Cyclic conversion found. You may want to check if a dictionary is missing no_reverse."
		}

		if ($x_to_y) { return -1 }
		if ($y_to_x) { return 1 }

		if ($y.value.Contains($x.value)) { return -1 }
		if ($x.value.Contains($y.value)) { return 1 }

		# Put shorter values later in the conversion
		if ($x.value.Length -lt $y.value.Length) { return -1 }
		if ($x.value.Length -gt $y.value.Length) { return 1 }
		# Put shorter replacements earlier in the conversion
		if ($x.replacement.Length -lt $y.replacement.Length) { return 1 }
		if ($x.replacement.Length -gt $y.replacement.Length) { return -1 }
		# Put replacements shorter than values earlier ; prevents substring match
		if ($x.replacement.Length -lt $y.value.Length) { return 1 }
		if ($x.replacement.Length -gt $y.value.Length) { return -1 }

		if ($x.value -lt $y.value) { return -1 }
		if ($x.value -gt $y.value) { return 1 }
		return 0 # the values are equal
	}
}

function Get-ModVersion {
	$version = Select-String -Path "$src\info.txt" '\bNUMERIC_VERSION:(\d+)' | % Matches | % Groups | Select-Object -Index 1
	$version ??= '100'
	return $version
}

function indent {
	param (
		[Parameter(Position = 0, Mandatory)] [string] $CopyFrom,
		[Parameter(Position = 1           )] [string] $AddTo = '',
		[Parameter(Position = 2           )] [uint]   $Increase = 0
	)

	$CopyFrom -match '\A[\t ]*'
	return $Matches[0], $("`t" * $Increase), $AddTo -join ''
}

function dfdiff {
	[CmdletBinding()] param (
		[Parameter(Position = 0, Mandatory, ValueFromPipeline)] [string] $First,
		[Parameter(Position = 1, Mandatory, ValueFromPipeline)] [string] $Second
	)

	process {
		if (-not $First -or $First.Length -eq 0) {
			throw "No first set provided."
		}
		if (-not $Second -or $Second.Length -eq 0) {
			throw "No first set provided."
		}

		$set_first = $First | Select-String -Pattern '(\[[^\n\]]+\])' -AllMatches | % {
			$_.Matches | % { $_.Groups[1].Value }
		}
		$set_second = $Second | Select-String -Pattern '(\[[^\n\]]+\])' -AllMatches | % {
			$_.Matches | % { $_.Groups[1].Value }
		}

		if (-not $set_first -or $set_first.Length -eq 0) {
			throw "First set tokens are empty."
		}
		if (-not $set_second -or $set_second.Length -eq 0) {
			throw "Second set tokens are empty."
		}

		return Compare-Object $set_first $set_second | ? SideIndicator -eq '=>' | % InputObject
	}
}

# --- Lifecycle ---------------------------------------------------------------------------------- #

$version = Get-ModVersion
$folder = "$mod ($version)"

function Backup-Mod {
	$version = Get-ModVersion
	$folder = "$mod ($version)"

	Remove-Item -Path "$out\backup\$folder" -Recurse -Force -EA 0 | Out-Null
	New-Item -Path "$out\backup\$folder" -ItemType Directory -Force | Out-Null

	Get-ChildItem -Path "$out\$folder\*" -File -Recurse -EA 0 |
	Move-Item -Destination "$out\backup\$folder\" -Force | Out-Null
}

$tag_comparer = [CvConvertTagComparer]::new()
$token_conversions = [ordered] @{}
$token_conversions_reverse = [ordered] @{}

function New-Mod {
	$version = Get-ModVersion
	$folder = "$mod ($version)"

	New-Item -Type Directory -Path "$out\$folder"                 -Force | Out-Null
	New-Item -Type Directory -Path "$out\$folder\graphics"        -Force | Out-Null
	New-Item -Type Directory -Path "$out\$folder\graphics\images" -Force | Out-Null
	New-Item -Type Directory -Path "$out\$folder\objects"         -Force | Out-Null
	New-Item -Type Directory -Path "$out\$folder\sounds"          -Force | Out-Null

	foreach ($name in $mod_dictionaries.Keys) {
		$task = $mod_dictionaries[$name]
		$tokens = $task.tokens ?? @($task.token)
		$source = $task.source
		$set = [System.Collections.Generic.SortedSet[pscustomobject]]::new($tag_comparer)
		try {
			Get-Content "$src\$source" | % {
				$subs = $_ -split ',' ;
				if ($subs[0] -and $subs[0] -ne $subs[1]) {
					[void] $set.Add(@{
							value       = $subs[0]
							replacement = $subs[1]
						})
				}
			}

			$token_conversions[$name] = [pscustomobject] @{
				dictionary = $set
				tokens     = $tokens | Get-Unique
			}
		}
		catch { $null }
	}

	foreach ($name in $mod_dictionaries.Keys) {
		$task = $mod_dictionaries[$name]
		$tokens = $task.tokens ?? @($task.token)
		$source = $task.source
		if (-not $task.no_reverse) {
			$set = [System.Collections.Generic.SortedSet[pscustomobject]]::new($tag_comparer)
			try {
				Get-Content "$src\$source" | % {
					$subs = $_ -split ',' ;
					if ($subs[1] -and $subs[0] -ne $subs[1]) {
						[void] $set.Add(
							@{
								value       = $subs[1]
								replacement = $subs[0]
							}
						)
					}
				}
				$token_conversions_reverse[$name] = [pscustomobject] @{
					dictionary = $set
					tokens     = $tokens | Get-Unique
				}
			}
			catch { $null }
		}
	}

	$script:start_time = Get-Date
}

$always_deploy = $true
$script:deployed = $false

function Deploy-Mod {
	if (-not $always_deploy -and (Read-Host "Overwrite mod install? y/n") -inotmatch "y") {
		$script:deployed = $false
		return
	}

	$version = Get-ModVersion
	$folder = "$mod ($version)"

	Remove-Item -Path "$df\$im\$folder" -Recurse -Force -EA 0
	Remove-Item -Path "$df\$mu\$folder" -Recurse -Force -EA 0

	$install_one = New-Item -Force -Type Directory "$df\$im\$folder"
	$install_two = New-Item -Force -Type Directory "$df\$mu\$folder"

	$deploy_flags = '/S /PURGE /COPY:DA /DCOPY:DA /XD .* /XF *.ps1 *.pdn'
	$install_one | ? { $_ } | % { robocopy "$out\$folder\" $_ $deploy_flags.Split(' ') | Out-Null }
	$install_two | ? { $_ } | % { robocopy "$out\$folder\" $_ $deploy_flags.Split(' ') | Out-Null }

	$script:deployed = $true
}

$loud = $true

function Out-Step {
	[CmdletBinding()] param (
		[Parameter(ValueFromPipeline, Mandatory)] [string] $Section,
		[Parameter(ValueFromPipeline, Mandatory)] [string] $Name
	)

	if ($loud) { "Progress on $Section`: performing step $Name" | Out-Host }
}

function Out-Report {
	if ($script:deployed) {
		$results = Get-ChildItem -Path "$out\$folder" -File -Recurse

		$num_all = $results.Count
		$num_txt = ($results | ? Extension -eq '.txt').Count ?? 0
		$num_png = ($results | ? Extension -eq '.png').Count ?? 0

		$len_all = '{0:N0}' -f ($results | % Length | Measure -Sum | % { $_.Sum / 1KB })
		$len_txt = '{0:N0}' -f ($results | ? Extension -eq '.txt' | % Length | Measure -Sum | % { $_.Sum / 1KB })
		$len_png = '{0:N0}' -f ($results | ? Extension -eq '.png' | % Length | Measure -Sum | % { $_.Sum / 1KB })

		""
		tree "$out\$folder" /F | Select-Object -Skip 2
		""
		"$mod contains $num_all files ($num_txt txt, $num_png png)"
		"with a total size of $len_all KB ($len_txt txt, $len_png png)"
		""
		"Done at $(Get-Date) in $('{0:N2}' -f ((Get-Date) - $script:start_time).TotalSeconds) seconds."
	}
	else {
		"`nDid not deploy."
	}
}

function Debug-ModIssues {
	$mod_files = Get-ChildItem -Path $out\$folder -Filter '*.txt' -Recurse -File
	$bad_files = $mod_files | ? { $_.BaseName -notlike "dictionary*" -and $_.BaseName -ne (gc $_ -total 1) }

	foreach ($bad_file in $bad_files) {
		"File $($bad_file.BaseName) has wrong identifier: $(gc $bad_file -total 1)" | Out-Host
	}
}

# --- Task handling ------------------------------------------------------------------------------ #

function Copy-RawToMod {
	[CmdletBinding()] param (
		[Parameter(ValueFromPipeline)] [string[]] $Path
	)

	$Path | ? { $_ } | Copy-Item -Path { "$df\data\vanilla\$_" } -Recurse -Force -Destination {
		return $(
			switch ($_) {
				{ $_ -match 'images' } { "$out\$folder\graphics\images\" ; break }
				{ $_ -match 'graphics' } { "$out\$folder\graphics\" ; break }
				{ $_ -match 'sounds' } { "$out\$folder\sounds\" ; break }
				default { "$out\$folder\objects\" ; break }
			}
		)
	}
}

function Convert-Raw {
	[CmdletBinding()] param (
		[Parameter(ValueFromPipeline, Mandatory)] [hashtable] $Task
	)

	$sources = $Task.sources ? $Task.sources : @($Task.source)
	$target = $Task.target

	$format = '(?<=\[{0}(?:\b{1}\b):(?:[^\n\]:]*:)*)(?:{2})(?=[\]:])'
	$command = $Task.command ? '(?:(?:GO_TO_TAG|CV_(?:ADD|NEW)_C?TAG|CV_REMOVE_C?TAG):)?' : ''

	$converts = $token_conversions.GetEnumerator() | ? { $_.Name -in $sources }

	foreach ($file in (Get-ChildItem -Path "$out\$folder\$target" -Recurse -File)) {
		$content = [System.IO.File]::ReadAllText($file)

		foreach ($convert in $converts) {
			$tokens = $convert.Value.tokens
			$dict = $convert.Value.dictionary

			foreach ($token in $tokens) {
				$dict | % {
					$content = $content -replace ($format -f $command, $token, $_.value), $_.replacement
				}
			}
		}

		[System.IO.File]::WriteAllText($file, $content) # todo: wasteful
	}
}

function Edit-ObjectEntry {
	[CmdletBinding()] param(
		[parameter(ValueFromPipeline, Mandatory)] [hashtable] $Task
	)

	$target = $Task.target
	$type = $Task.type
	$entry = $Task.entry
	$pattern = $Task.pattern
	$replace = $Task.replace ?? ''

	foreach ($file in $(Get-ChildItem -Path "$out\$folder\$target" -Recurse -File)) {
		$content = [System.IO.File]::ReadAllText($file)
		$pattern = '(?s)(?<=\[{0}:(?:{1})\](?:(?!\[{0}:).)+)(?:{1})' -f $type, $entry, $pattern
		$content = $content -replace $pattern, $replace
		[System.IO.File]::WriteAllText($file, $content)
	}
}

function Remove-TokenEntry {
	[CmdletBinding()] param (
		[Parameter(ValueFromPipeline, Mandatory)] [hashtable] $Task
	)

	$list = $Task.list
	$source = $Task.source
	$target = $Task.target
	$token = $Task.token
	$terminal = $Task.terminal ?? $token

	# Conversion dictionaries convert between non-equal values, but the dictionary files can contain matched pairs.

	$removes = $list ?? (
		Get-Content "$src\$source" | & {
			process {
				$s = $_ -split ','
				if ($s[0] -eq $s[1]) { $_[0] }
			}
		}
	)

	if ($removes) {
		foreach ($remove in $removes) {
			$file = Get-Item -Path "$out\$folder\$target"
			$content = [System.IO.File]::ReadAllText($file)
			$pattern = [regex] ('\[(?:{0}):(?:{1})\].*\n(?:(?!\[(?:{2}):)[\S\s])+' -f $token, $remove, $terminal)
			$content = $pattern.Replace($content, '', 1)
			[System.IO.File]::WriteAllText($file, $content)
		}
	}
}

function Add-CreatureVariation {
	[CmdletBinding()] param (
		[Parameter(ValueFromPipeline, Mandatory)] [hashtable] $Task
	)

	$name = $Task.name
	$prepend = $Task.prepend
	$sources = $Task.sources ? $Task.sources : @($Task.source)
	$reverse = $Task.reverse ?? $false
	$append = $Task.append
	$target = $Task.target

	$path = "$out\$folder\$target"

	if (-not (Test-Path -Path $path)) {
		$file = New-Item -Path $path -ItemType File
		Add-Content $file $file.BaseName
		Add-Content $file "`n[OBJECT:CREATURE_VARIATION]`n"
	}

	$variation = "`n[CREATURE_VARIATION:$name]"

	if ($prepend) { $variation += "`n$prepend" }

	$converts = ($reverse ? $token_conversions_reverse : $token_conversions).GetEnumerator() | ? { $_.Name -in $sources }

	# Creature variations convert arguments within tokens via *sub*string find and replace.
	# Since matches are not exact and don't respect word boundaries, problems are possible.
	$format = "`n`t[CV_CONVERT_TAG]`n`t`t[CVCT_MASTER:{0}]`n`t`t[CVCT_TARGET:{1}]`n`t`t[CVCT_REPLACEMENT:{2}]"

	foreach ($convert in $converts) {
		$tokens = $convert.Value.tokens
		$dict = $convert.Value.dictionary

		foreach ($token in $tokens) {
			$dict | % { $variation += $format -f $token, $_.value, $_.replacement }
		}
	}

	if ($append) { $variation += "`n$append" }

	Add-Content -Path $path -Value $variation
}

# todo: most build time is spent here in IO; load each file once and run all selects on it

function Add-SelectObjectEntry {
	[CmdletBinding()] param (
		[Parameter(ValueFromPipeline, Mandatory)] [hashtable] $Tasks
	)

	$outputs = [ordered] @{}

	foreach ($name in $Tasks.Keys) {
		Out-Step -Section 'Select objects' -Name $name

		$Task = $Tasks[$name]

		$module = $Task.module
		$target = $Task.target
		$object = $Task.object
		$output = $Task.output ?? "objects\$($object)_patch_$mod.txt".ToLower()
		$terminal = $Task.terminal ?? $object
		$filter = $Task.filter ?? '\A\z'
		$process = $Task.process ?? { $null }
		$prepend = $Task.prepend
		$append = $Task.append

		if (-not ($entries = $outputs[$output])) {
			$entries = [ordered] @{}
			$outputs[$output] = $entries
		}

		$prepend = $prepend | ? { $_ } | Get-Content -Path { "$src\$_" } -Raw
		$append = $append | ? { $_ } | Get-Content -Path { "$src\$_" } -Raw

		# Match the entire object entry and its subtokens. Capture its name in group $1.
		$pattern = '\[(?:{0}):([^\n\]:]+)\].*?\n(?:(?!\[(?:{1}):)[\S\s])+' -f $object, $terminal

		# Extract and replace token arguments via dictionary substitution.
		foreach ($file in (Get-ChildItem -Path "$df\data\vanilla\$module\$target" -File -Recurse)) {
			$file_content = Get-Content $file -Raw
			$matched = $file_content | Select-String -Pattern $pattern -AllMatches
			$matched | ? { $_.Matches.Value -notmatch $filter } | % {
				$_.Matches | % {
					$entry_content = $_.Groups[0].Value
					$entry_name = $_.Groups[1].Value
					$from_subtokens = (& $process -content $entry_content -name $entry_name) | ? { $_ } | Out-String | % TrimEnd
					$all_strings = $entries[$entry_name], $prepend, $from_subtokens, $append | ? { $_ -and $_.Length -gt 3 }
					$entries[$entry_name] = $all_strings -join "`n"
				}
			}
		}
	}

	foreach ($output in $outputs.Keys) {
		$path = "$out\$folder\$output"
		if (Test-Path -Path $path) {
			$file = Get-Item -Path $path
		}
		else {
			$file = New-Item -Path $path -ItemType File -Force
			Add-Content -Path $file -Value $file.BaseName         # required
			Add-Content -Path $file -Value "`n[OBJECT:$object]`n" # required
		}

		$content = ''
		$entries = $outputs[$output]
		$selects = $object -replace '_.*$', '' # e.g. ITEM_ARMOR => ITEM

		foreach ($entry_name in $entries.Keys) {
			$entry_content = $entries[$entry_name]
			if ($entry_content -and $entry_content.Length -gt 2) {
				$content += "[SELECT_$selects`:$entry_name]`n$entry_content`n" -replace '\n+\z', "`n`n"
			}
		}

		Add-Content -Path $file -Value $content
	}
}

function Add-ContentBody {
	[CmdletBinding()] param (
		[Parameter(ValueFromPipeline, Mandatory)] [hashtable] $Task
	)

	$source = $Task.source
	$target = $Task.target
	$remove = $Task.remove ?? 0

	$path = "$out\$folder\$target"
	Add-Content -Path $path -Value "`n`n$('=' * 100)`n"
	Add-Content -Path $path -Value (Get-Content -Path "$src\$source" | Select-Object -Skip $remove)
}

function Edit-InsertByLine {
	[CmdletBinding()] param (
		[Parameter(ValueFromPipeline, Mandatory)] [hashtable] $Task
	)

	$target = $Task.target
	$after = $Task.after
	$before = $Task.before
	$value = $Task.value ?? (Get-Content -Path "$src\$($Task.source)")
	$indent = $Task.indent

	foreach ($file in (Get-ChildItem -Path "$out\$folder\$target" -File -Recurse)) {
		(Get-Content -Path $file) | % {
			if ($before -and $_ -match $before) { if ($indent) { indent $_ $value } else { $value } }
			$_ # current line->output
			if ($after -and $_ -match $after) { if ($indent) { indent $_ $value } else { $value } }
		} | Set-Content -Path $file
	}
}


## ---------------------------------------------------------------------------------------------- ##
## -- PROGRAM ----------------------------------------------------------------------------------- ##

Backup-Mod && New-Mod

# Raw dictionary conversions

Copy-RawToMod -Path $raws_convert

foreach ($name in $conversions.Keys) {
	Out-Step -Section 'Conversions' -Name $name
	$conversions[$name] | Convert-Raw
}

# Raw edits

Copy-RawToMod -Path $raws_copy

foreach ($name in $raws_remove.Keys) {
	Out-Step -Section 'Removals' -Name $name
	$raws_remove[$name] | Remove-TokenEntry
}
foreach ($name in $raws_modify.Keys) {
	Out-Step -Section 'Creature edits' -Name $name
	$raws_modify[$name] | Edit-ObjectEntry
}
foreach ($name in $raws_insert.Keys) {
	Out-Step -Section 'Inserts' -Name $name
	$raws_insert[$name] | Edit-InsertByLine
}
foreach ($name in $raws_append_mods.Keys) {
	Out-Step -Section 'Appends' -Name $name
	$raws_append_mods[$name] | Add-ContentBody
}
foreach ($name in $mod_creature_variation.Keys) {
	Out-Step -Section 'Creature variation' -Name $name
	$mod_creature_variation[$name] | Add-CreatureVariation
}

Add-SelectObjectEntry -Tasks $mod_select # Each object gets its selects bundled together.

# Mod additions and overwrites

$mod_info     | Copy-Item -Path { "$src\$_" } -Destination "$out\$folder\"                 -Force
$mod_objects  | Copy-Item -Path { "$src\$_" } -Destination "$out\$folder\objects\"         -Force
$mod_graphics | Copy-Item -Path { "$src\$_" } -Destination "$out\$folder\graphics\"        -Force
$mod_images   | Copy-Item -Path { "$src\$_" } -Destination "$out\$folder\graphics\images\" -Force
$mod_sounds   | Copy-Item -Path { "$src\$_" } -Destination "$out\$folder\sounds\"          -Force

# Deploy and clean up artifacts

Deploy-Mod && Out-Report

Debug-ModIssues
