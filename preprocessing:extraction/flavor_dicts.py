from nltk.stem.snowball import SnowballStemmer

stemmer = SnowballStemmer('english')

woody = {'new wood': ['wood', 'resinous', 'sandalwood', 'ginger', 'pepper', 'allspice', 'nutmeg', 'spice', 'spici'], 
		'old wood': ['musty', 'bung', 'cellar', 'pencil', 'cork', 'ink', 'metallic', 'camphor'],
		'vanilla': ['vanilla', 'custard', 'caramel', 'meringue', 'nougat', 'cake','sponge', 'toffee'],
		'toasted': ['toast', 'brulee', 'burnt', 'coffee', 'fennel', 'aniseed', 'licorice', 'liquorice']}

winey = {'sherried': ['sherry', 'chardonnay', 'sauternes', 'port', 'fino', 'oloroso', 'madeira'],
		'nutty': ['nut', 'walnut', 'hazelnut' ,'hazel' ,'almond', 'praline', 'marzipan'],
		'chocolate': ['cream', 'creamy', 'butter', 'milk', 'cocoa', 'chocolate'],
		'oily': ['oil', 'suntan'],
		'other': ['wine', 'winey']}

fruity = {'citrus': ['orange', 'tangerine', 'zest', 'kiwi', 'nectarine', 'lemon', 'lime', 'citrus', 'citric'],
		 'fresh fruit': ['apple', 'pear', 'peach','apricot'],
		 'cooked fruit': ['candied', 'sugar', 'jam', 'marmalade'],
		 'dried fruit': ['raisin', 'fig', 'apricot', 'prune', 'peel', 'minced'],
		 'solvent': ['varnish', 'paint', 'gum'],
		 'other': ['fruit', 'fruity']}	

peaty = {'medicinal': ['medicine', 'creosote', 'iodine', 'carbolic', 'hospital', 'lint', 'tar', 'seaweed', 'oil', 'diesel'],
		'smokey': ['smoke', 'smoky' 'burnt', 'bonfire', 'fire', 'lapsang'],
		'keppery': ['shell', 'shellfish', 'salmon', 'oyster', 'anchovy'],
		'mossy': ['moss', 'birch', 'bog', 'damp', 'myrtle', 'earth', 'earthy','turf', 'hemp', 'rope', 'fishing'],
		'other': ['peaty', 'peat']}

floral = {'fragrant': ['perfume', 'softener', 'carnation', 'coconut', 'lavender'],
		  'greenhouse': ['geranium', 'florist', 'parmaviolet'],
		  'leafy': ['leaf', 'leaves', 'green', 'lawn', 'grass', 'clippings', 'fir', 'pine'],
		  'haylike': ['mown', 'hay', 'barn', 'herbal', 'sage', 'mulch'],
		  'other': ['floral']}


feinty = {'sweaty':['buttermilk', 'cheese', 'yeast', 'shoe', 'sweat'],
		  'tobacco': ['tea', 'tobacco', 'ash'],
		  'leather': ['upholstery', 'cowhide', 'polished', 'leather', 'wax', 'waxy'],
		  'honey': ['honey', 'mead', 'beeswax'],
		  'other': ['feinty', 'feint']}

sulphur = {'vegitative': ['brackish', 'cabbage', 'turnip', 'stagnant', 'marsh'],
			'coal': ['carbide', 'cordite', 'match', 'matchbox','firework', 'coal'],
			'rubber': ['eraser', 'tire', 'bakelite', 'cables'],
			'sandy': ['laundry', 'starch', 'linen', 'sand', 'beach'],
			'other': ['sulphur']}		


cereal = {'mash': ['porridge', 'draff', 'weetabix', 'maize', 'mash'], 
          'vegetable': ['potato', 'scone', 'swede', 'corn'],
          'maltextract': ['bran', 'cattle', 'marmite', 'cake', 'malt'],
          'husky': ['caff', 'hops', 'mousey', 'pot', 'ale'],
          'yeasty': ['pork', 'sausage', 'meat', 'yeast', 'gravy', 'garlloch']}



flavors = {'woody': woody, 'winey': winey, 'fruity': fruity, 'peaty': peaty, 
           'floral': floral, 'feinty': feinty, 'sulphur': sulphur, 
           'cereal': cereal}



def flatten_flavor(flavor):
	flat = []
	for key in flavor.keys():
		for item in flavor[key]:
			flat.append(item)
	return flat

flatFlavors = {key: {stemmer.stem(word) for word in flatten_flavor(flavors[key])} 
               for key in flavors.keys()}
