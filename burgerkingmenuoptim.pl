from pulp import *
import pandas as pd
import re

df = pd.read_excel("bking.xlsx")

# Ürün adlarının listelenmesi
urunlistesi = list(df['Name'])

# Ürünlerin kalori değerlerinin bir dict içine kaydedilmesi
kalori = dict(zip(urunlistesi,df['Enerji(kcal)']))

# Ürünlerin protein değerlerinin bir dict içine kaydedilmesi
protein = dict(zip(urunlistesi,df['Protein(g)']))

# Ürünlerin yağ değerlerinin bir dict içine kaydedilmesi
yag = dict(zip(urunlistesi,df['Yag(g)']))

# Ürünlerin karbonhidrat değerlerinin bir dict içine kaydedilmesi
karbonhidrat = dict(zip(urunlistesi,df['K,hidrat(g)']))

# Ürünlerin sodyum değerlerinin bir dict içine kaydedilmesi
sodyum = dict(zip(urunlistesi,df['Sodyum(mg)']))

urundegerleri = LpVariable.dicts("Urun",urunlistesi,lowBound=0,upBound=5,cat='Integer')

prob = LpProblem("BurgerKingMenuOptimizasyonu",LpMinimize)

prob += lpSum([kalori[i]*urundegerleri[i] for i in urunlistesi])

# Protein >= 50 g
prob += lpSum([protein[f]*urundegerleri[f] for f in urunlistesi]) >= 50.0, "ProteinMinimum"

# Yağ >= 65 g
prob += lpSum([yag[f]*urundegerleri[f] for f in urunlistesi]) >= 65.0, "YagMinimum"

# Karbonhidrat >= 310 g
prob += lpSum([karbonhidrat[f]*urundegerleri[f] for f in urunlistesi]) >= 310.0, "KarbonhidratMinimum"

# Sodyum >= 2400 mg
prob += lpSum([sodyum[f]*urundegerleri[f] for f in urunlistesi]) >= 2400.0, "SodyumMinimum"

prob.solve()
print("Problem Durumu:",LpStatus[prob.status], prob.solve(),"\n")

print("Olası Durumlar:", "\n Problem Çözüldü	“Optimal”	1", "\n Problem Çözülmedi	“Not Solved”	0", "\n Çözüm Mümkün Değil	“Infeasible”	-1", "\n Çözüm Ölçülemez	“Unbounded”	-2", "\n Çözüm Tanımsız	“Undefined”	-3\n")

print("###################################")

print("\nGünlük Besin Değerlerini Karşılayan Menü ve Ürün Adedi\n")

for v in prob.variables():
    if v.varValue>0:
        aa = re.sub("Urun_", "", v.name)
        bb = re.sub("_"," ",aa)
        print(format(round(value(v.varValue))), "adet", bb)

print("\nToplam Kalori Miktarı = ", format(round(value(prob.objective),2)), "(kcal)\n")

print("###################################")

print("\nBu Menüden Alacağınız Besin Değerleri \n")
for v in prob.variables():
    if v.varValue>0:
        aa = re.sub("Urun_", "", v.name)
        bb = re.sub("_"," ",aa)
        print(format(round(value(v.varValue))),"adet", bb)
        mydf=df[df["Name"] == bb]
        aba = mydf.iloc[0:, 1:6]
        aba["Enerji(kcal)"] = aba["Enerji(kcal)"].apply(lambda x: x*v.varValue)
        aba["Protein(g)"] = aba["Protein(g)"].apply(lambda x: x*v.varValue)
        aba["K,hidrat(g)"] = aba["K,hidrat(g)"].apply(lambda x: x*v.varValue)
        aba["Yag(g)"] = aba["Yag(g)"].apply(lambda x: x*v.varValue)
        aba["Sodyum(mg)"] = aba["Sodyum(mg)"].apply(lambda x: x*v.varValue)
        print(aba,"\n")