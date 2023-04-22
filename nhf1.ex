defmodule Nhf1 do
  @moduledoc """
  Kemping
  @author "Várai Axel "
  @date   "2022-10-14"
  ...
  """

  # sor száma (1-től n-ig)
  @type row :: integer
  # oszlop száma (1-től m-ig)
  @type col :: integer
  # egy parcella koordinátái
  @type field :: {row, col}

  # a sátrak száma soronként
  @type tents_count_rows :: [integer]
  # a sátrak száma oszloponként
  @type tents_count_cols :: [integer]

  # a fákat tartalmazó parcellák koordinátái lexikálisan rendezve
  @type trees :: [field]
  # a feladványleíró hármas
  @type puzzle_desc :: {tents_count_rows, tents_count_cols, trees}

  # a sátorpozíciók iránya: north, east, south, west
  @type dir :: :n | :e | :s | :w
  # a sátorpozíciók irányának listája a fákhoz képest
  @type tent_dirs :: [dir]

  @spec satrak(pd :: puzzle_desc) :: tss :: [tent_dirs]
  # tss a pd feladványleíróval megadott feladvány összes megoldásának listája, tetszőleges sorrendben

  def satrak(pd) do
    {tents_count_rows, tents_count_cols, trees} = pd
    oszlop_darab = length(tents_count_cols) + 1
    sor_darab = length(tents_count_rows) + 1
    fak_darab = length(trees)
    elso_sor = [" " | tents_count_cols]

    matrix_also_resze =
      for j <- 0..(sor_darab - 2) do
        for i <- (j * oszlop_darab + 1)..((j + 1) * oszlop_darab) do
          if rem(i - 1, oszlop_darab) === 0 do
            Enum.at(tents_count_rows, div(i - 1, oszlop_darab))
          else
            fa_vagy_ures(trees, j + 1, rem(i - 1, oszlop_darab), 0)
          end
        end
      end

    ## ez egy "ures" matrix azaz meg satrak nelkuli matrix
    kezdo_matrix = [elso_sor | matrix_also_resze]

    fak_iranyokkal =
      for i <- 0..(fak_darab - 1) do
        length(
          get_elerheto_iranyok(
            kezdo_matrix,
            tents_count_rows,
            tents_count_cols,
            Enum.at(trees, i),
            [],
            0,
            []
          )
        )
      end

    atlag_fa_egy_sorban = div(fak_darab, sor_darab - 1) + 1

    fak_fontossag_szammal =
      okosan_pontozza_a_fakat(fak_darab, atlag_fa_egy_sorban, fak_iranyokkal, 1, 0, [])

    vegso_fa_tupple = fak_fontossag_szammal |> List.keysort(0)

    vegso_fa_sorrend =
      for i <- 0..(fak_darab - 1) do
        Enum.at(vegso_fa_tupple, i) |> elem(1)
      end

    eredeti_fasorrend_a_vegso_fakban = fak_visszarendezese(vegso_fa_sorrend, 0, 0, [])

    megoldas_tomb_rossz_sorrendbe =
      List.flatten(
        rekurziv_megoldas(
          kezdo_matrix,
          tents_count_rows,
          tents_count_cols,
          vegso_fa_sorrend,
          trees,
          fak_darab,
          [],
          0,
          [],
          []
        )
      )

    ideiglenes_megoldas = Enum.filter(megoldas_tomb_rossz_sorrendbe, &(!is_nil(&1)))
    megoldas_hossza = div(length(ideiglenes_megoldas) + 1, fak_darab)
    # tss = vegso megoldas
    tss =
      if(megoldas_hossza > 0) do
        for j <- 0..(megoldas_hossza - 1) do
          vissza_mapeles_az_eredeti_fak_sorrendjere(
            ideiglenes_megoldas,
            eredeti_fasorrend_a_vegso_fakban,
            fak_darab,
            0,
            j,
            []
          )
        end
      else
        []
      end
  end

  @spec vissza_mapeles_az_eredeti_fak_sorrendjere(
          ideiglenes_megoldas :: list(Enum),
          eredeti_fasorrend_a_vegso_fakban :: list(Enum),
          fak_darab :: integer,
          i :: integer,
          j :: integer,
          eredm :: tent_dirs
        ) :: eredm :: tent_dirs
  # ideiglenes_megoldas az az a lista amiben az osszes jo irany van tagolatlanul
  # eredeti_fasorrend_a_vegso_fakban egy lista megadja, hogy az uj fa listaban hanyadik elem a regiben egy elem
  # fak_darab - fak darab szama
  # i belso iterator ami a satrakon megy vegig
  # j ez egy külső iterátor ami megadja, hogy hanyadik egesz megoldasnal tartunk
  # eredm eredmenyek listaja
  # Az eredeti fa sorrend alapjan rakja be az ideiglenes
  # megoldasbol a eredm-ba a megoldast ezzel visszarendezi
  # eredeti sorrendbe a fakat/satrakat
  defp vissza_mapeles_az_eredeti_fak_sorrendjere(
         ideiglenes_megoldas,
         eredeti_fasorrend_a_vegso_fakban,
         fak_darab,
         i,
         j,
         eredm
       ) do
    if(i < fak_darab) do
      irany =
        Enum.at(
          ideiglenes_megoldas,
          Enum.at(eredeti_fasorrend_a_vegso_fakban, i) + j * fak_darab
        )

      vissza_mapeles_az_eredeti_fak_sorrendjere(
        ideiglenes_megoldas,
        eredeti_fasorrend_a_vegso_fakban,
        fak_darab,
        i + 1,
        j,
        eredm ++ [irany]
      )
    else
      eredm
    end
  end

  @spec fak_visszarendezese(
          vegso_fa_sorrend :: list(Enum),
          i :: integer,
          keresett :: integer,
          eredm :: list(Enum)
        ) :: eredm :: list(Enum)
  # vegso_fa_sorrend fak listajanak egy alternativ sorrendje
  # i iterator ami vegig megy a vegso_fa_sorrend listan
  # keresett iterator ami vegig megy a fa lista hosszan
  # eredm az eredmeny listaja
  # Visszaadja, hogy az eredeti fa lista elemei
  # hanyadik helyre kerultek az altalam rendezett fa sorrendben
  # amelynek a sorrendjen haladt vegig vegul a megoldas kereses
  defp fak_visszarendezese(vegso_fa_sorrend, i, keresett, eredm) do
    if keresett < length(vegso_fa_sorrend) do
      if Enum.at(vegso_fa_sorrend, i) == keresett do
        fak_visszarendezese(vegso_fa_sorrend, 0, keresett + 1, eredm ++ [i])
      else
        fak_visszarendezese(vegso_fa_sorrend, i + 1, keresett, eredm)
      end
    else
      eredm
    end
  end

  @spec rekurziv_megoldas(
          matrix :: list(list(Enum)),
          tents_count_rows :: [integer],
          tents_count_cols :: [integer],
          vegso_fa_sorrend :: [integer],
          trees :: [field],
          fak_darab :: integer,
          tents :: [field],
          i :: integer,
          megoldasok :: list(list(Enum)),
          egy_megoldas :: list(Enum)
        ) :: megoldasok :: [tent_dirs]
  # matrix a palya matrixa
  # tents_count_rows
  # tents_count_cols
  # vegso_fa_sorrend a fak olyan sorrendjenek listaja amit en
  # allitottam ossze egy fuggvennyel
  # trees fak tombje
  # fak_darab fak darab szama
  # tents satrak listaja
  # i iterator ami vegig megy az osszes fan
  # megoldasok az osszes megoldas, egyben ez a visszateresi ertek is
  # egy_megoldas egy teljes rekurzio azaz eler az utolso fahoz es tud rakni-nak
  # az iranyokkal teli listaja
  # Ez a fuggveny keresi meg a megoldasokat.
  # Addig nyit rekurziokat az iranyokkal amíg van irany szabad iranya a
  # kovetkezo elemnek es ezek mellett a matrixot mindig frissitem
  # a vegen csak akkor rakom be a megoldasok listaba az egy_megoldas-t
  # ha nem maradt pozitiv szam a matrix elso sor illetve oszlopaban
  defp rekurziv_megoldas(
         matrix,
         tents_count_rows,
         tents_count_cols,
         vegso_fa_sorrend,
         trees,
         fak_darab,
         tents,
         i,
         megoldasok,
         egy_megoldas
       ) do
    if i < fak_darab do
      iranyok =
        get_elerheto_iranyok(
          matrix,
          tents_count_rows,
          tents_count_cols,
          Enum.at(trees, Enum.at(vegso_fa_sorrend, i)),
          tents,
          0,
          []
        )

      if length(iranyok) > 0 do
        for j <- 0..(length(iranyok) - 1) do
          {sor, oszlop} =
            get_tent(Enum.at(trees, Enum.at(vegso_fa_sorrend, i)), Enum.at(iranyok, j))

          csere_sor = List.replace_at(Enum.at(matrix, sor + 1), oszlop + 1, Enum.at(iranyok, j))
          matrix = List.replace_at(matrix, sor + 1, csere_sor)

          csere_tent_rows =
            List.replace_at(tents_count_rows, sor, Enum.at(tents_count_rows, sor) - 1)

          csere_tent_cols =
            List.replace_at(tents_count_cols, oszlop, Enum.at(tents_count_cols, oszlop) - 1)

          rekurziv_megoldas(
            matrix,
            csere_tent_rows,
            csere_tent_cols,
            vegso_fa_sorrend,
            trees,
            fak_darab,
            tents ++ [{sor + 1, oszlop + 1}],
            i + 1,
            megoldasok,
            egy_megoldas ++ [Enum.at(iranyok, j)]
          )
        end
      end
    else
      sor_ok = ellenorzi_az_elso_sor_v_oszlopot(tents_count_rows, 0, [])
      oszlop_ok = ellenorzi_az_elso_sor_v_oszlopot(tents_count_cols, 0, [])

      if sor_ok == [] && oszlop_ok == [] do
        megoldasok ++ [egy_megoldas]
      end
    end
  end

  @spec ellenorzi_az_elso_sor_v_oszlopot(lista :: [integer], i :: integer, eredm :: [Enum]) ::
          eredm :: [Enum]
  # lista az ellenorzott tomb ez a matrix elso sora vagy oszlopa
  # i iterator ami vegig megy a tombon
  # eredm az eredmeny
  # Megnezi hogy az első sor v első oszlopban (lista),
  # hogy nem maradt-e pozitiv szam,
  # azaz mindegyik sor illetve oszlopba eleg sator kerult
  # [1] ha maradt olyan oszlop/sor ahova kellett volna meg satornak kerulnie
  # egyebkent ures tomb marad (vagyis amit eredetileg megkapott)
  defp ellenorzi_az_elso_sor_v_oszlopot(lista, i, eredm) do
    if i < length(lista) - 1 do
      if Enum.at(lista, i) > 0 do
        eredm ++ [1]
      else
        ellenorzi_az_elso_sor_v_oszlopot(lista, i + 1, eredm)
      end
    else
      eredm
    end
  end

  @spec get_tent({sor :: integer, oszlop :: integer}, irany :: dir) :: eredm :: tuple()
  # sor ahol a fa van
  # oszlop ahol a fa van
  # irany az az irany amerre rakjuk a satrat
  # Visszaadja az irany alapjan a sor,oszlop szamot a matrixban
  defp get_tent({sor, oszlop}, irany) do
    case irany do
      :w -> {sor - 1, oszlop - 2}
      :n -> {sor - 2, oszlop - 1}
      :e -> {sor - 1, oszlop}
      :s -> {sor, oszlop - 1}
    end
  end

  @spec okosan_pontozza_a_fakat(
          fak_darab :: integer,
          atlag_fa_egy_sorban :: integer,
          fak_iranyokkal :: [integer],
          kis_lepes_iterator :: integer,
          i :: integer,
          eredm :: tuple()
        ) :: eredm :: tuple()
  # fak_darab a fak darab szama
  #  atlag_fa_egy_sorban ez egy szam
  #  fak_iranyokkal a fak sorrendjeben azoknak az
  # iranyoknak a szama amerre rakhatnak satrat
  #  kis_lepes_iterator ezt akkor novelem ha 2 iranyut pontozunk hogy
  # ezek mindig atlag fanyival elorebb keruljenek a fak soraban kesobb majd
  #  i vegig megy a fakon
  #  eredm ez az eredmeny
  # Pontozza a fakat aszerint hogy hany iranyba lehet rakni satrat
  # ha 1 akkor a legkisebb erteket kapja
  # ha 2 akkor ugy kap pontot hogy az atlag fa/sor darabbal előrébb
  # kerüljön majd sorba rendezés után a rendezett listában
  # ha 3 v 4 akkor ezek egymáshoz képest megtartják a sorrendjüket

  defp okosan_pontozza_a_fakat(
         fak_darab,
         atlag_fa_egy_sorban,
         fak_iranyokkal,
         kis_lepes_iterator,
         i,
         eredm
       ) do
    if(i < fak_darab) do
      iranyok_szama = Enum.at(fak_iranyokkal, i)

      if iranyok_szama == 1 do
        okosan_pontozza_a_fakat(
          fak_darab,
          atlag_fa_egy_sorban,
          fak_iranyokkal,
          kis_lepes_iterator + 1,
          i + 1,
          eredm ++ [{-1 * atlag_fa_egy_sorban, i}]
        )
      else
        if iranyok_szama == 2 do
          okosan_pontozza_a_fakat(
            fak_darab,
            atlag_fa_egy_sorban,
            fak_iranyokkal,
            kis_lepes_iterator + 1,
            i + 1,
            eredm ++ [{(i + 1 - kis_lepes_iterator) * atlag_fa_egy_sorban - 1, i}]
          )
        else
          okosan_pontozza_a_fakat(
            fak_darab,
            atlag_fa_egy_sorban,
            fak_iranyokkal,
            kis_lepes_iterator,
            i + 1,
            eredm ++ [{(i + 1) * atlag_fa_egy_sorban, i}]
          )
        end
      end
    else
      eredm
    end
  end

  @spec get_irany_es_koordinata(irany_iter :: integer, {sor :: integer, oszlop :: integer}) ::
          eredm :: tuple()
  # irany_iter ez egy integer ami az iranyt jeloli
  # {sor, oszlop} a matrixban a fa sor illetve oszlop koordinatai
  # eredm megadja azt a satort es koordinatait amit le lehet helyezni ebbol a fabol
  # Visszaadja a fahoz kepest iranyt es abba az iranyba levo negyzet koordinatait
  defp get_irany_es_koordinata(irany_iter, {sor, oszlop}) do
    if irany_iter == 0 do
      {:w, {sor, oszlop - 1}}
    else
      if irany_iter == 1 do
        {:n, {sor - 1, oszlop}}
      else
        if irany_iter == 2 do
          {:e, {sor, oszlop + 1}}
        else
          if irany_iter == 3 do
            {:s, {sor + 1, oszlop}}
          else
          end
        end
      end
    end
  end

  @spec get_elerheto_iranyok(
          matrix :: list(list(Enum)),
          tents_count_rows :: [integer],
          tents_count_cols :: [integer],
          tree :: field,
          tents :: [field],
          irany_iter :: integer,
          eredm :: [dir]
        ) :: eredm :: [dir]
  # matrix,
  # tents_count_rows,
  # tents_count_cols,
  # tree,
  # tents,
  # irany_iter,
  # eredm
  ## S iranyokat adja bele a eredm listaba ha ezekre az iranyokba lehet rakni satrat a megadott fa-tol
  defp get_elerheto_iranyok(
         matrix,
         tents_count_rows,
         tents_count_cols,
         tree,
         tents,
         3,
         eredm
       ) do
    {irany, {tent_sor, tent_oszlop}} = get_irany_es_koordinata(3, tree)

    if tent_sor < length(tents_count_rows) + 1 && tent_oszlop < length(tents_count_cols) + 1 &&
         Enum.at(Enum.at(matrix, tent_sor), tent_oszlop) == "-" do
      rakhato_sorba = sor_vagy_oszlop_ellenorzes(tent_sor, tents_count_rows)
      rakhato_oszlopba = sor_vagy_oszlop_ellenorzes(tent_oszlop, tents_count_cols)
      rakhato_negyzetbe = satrak_ellenorzes(tents, {tent_sor, tent_oszlop}, 0, [])

      if rakhato_sorba == true && rakhato_oszlopba == true && rakhato_negyzetbe == [] do
        eredm ++ [irany]
      else
        eredm
      end
    else
      eredm
    end
  end

  ## W,N,E iranyokat adja bele a eredm listaba ha ezekre az iranyokba lehet rakni satrat a megadott fa-tol
  defp get_elerheto_iranyok(
         matrix,
         tents_count_rows,
         tents_count_cols,
         tree,
         tents,
         irany_iter,
         eredm
       ) do
    {irany, {tent_sor, tent_oszlop}} = get_irany_es_koordinata(irany_iter, tree)

    if tent_sor < length(tents_count_rows) + 1 && tent_oszlop < length(tents_count_cols) + 1 &&
         Enum.at(Enum.at(matrix, tent_sor), tent_oszlop) == "-" do
      rakhato_sorba = sor_vagy_oszlop_ellenorzes(tent_sor, tents_count_rows)
      rakhato_oszlopba = sor_vagy_oszlop_ellenorzes(tent_oszlop, tents_count_cols)
      rakhato_negyzetbe = satrak_ellenorzes(tents, {tent_sor, tent_oszlop}, 0, [])

      if rakhato_sorba == true && rakhato_oszlopba == true && rakhato_negyzetbe == [] do
        get_elerheto_iranyok(
          matrix,
          tents_count_rows,
          tents_count_cols,
          tree,
          tents,
          irany_iter + 1,
          eredm ++ [irany]
        )
      else
        get_elerheto_iranyok(
          matrix,
          tents_count_rows,
          tents_count_cols,
          tree,
          tents,
          irany_iter + 1,
          eredm
        )
      end
    else
      get_elerheto_iranyok(
        matrix,
        tents_count_rows,
        tents_count_cols,
        tree,
        tents,
        irany_iter + 1,
        eredm
      )
    end
  end

  @spec sor_vagy_oszlop_ellenorzes(iter :: integer, lista :: [integer]) :: resp :: boolean
  # iter iterator a listaban
  # lista a matrix elso oszlopa vagy sora
  # resp a valasz, az adott ertek nem-e nulla
  # Megnezi az első sorban vagy oszlopban (lista) az adott elemre (iter-1)
  # hogy 0 e mert ha igen akkor már abba a sorba v oszlopba nem kerülhet sator
  defp sor_vagy_oszlop_ellenorzes(iter, lista) do
    if Enum.at(lista, iter - 1) != 0 do
      true
    else
      false
    end
  end

  @spec satrak_ellenorzes(
          tents :: trees,
          {x :: integer, y :: integer},
          j :: integer,
          eredm :: list(Enum)
        ) :: eredm :: list(Enum)
  # tents a satrak listaja
  # x,y a sor oszlop amit nezunk hogy van e korulotte masik sator
  # j iterator a satrak lsitajan
  # eredm az eredmeny listaja
  # Vegig megy a satrak listajan es megnézi hogy ugyanebben a listaban
  # van e olyan sator ami mellette van-e
  # majd visszaadja ezeket a "hibas" satrak koordinatait
  # ha ures tomb akkor lehet ide rakni satrat

  defp satrak_ellenorzes(tents, {x, y}, j, eredm) do
    if j < length(tents) do
      {j_x, j_y} = Enum.at(tents, j)

      if (j_x + 1 == x && (j_y + 1 == y || j_y == y || j_y - 1 == y)) ||
           (j_x - 1 == x && (j_y + 1 == y || j_y == y || j_y - 1 == y)) ||
           (j_x == x && (j_y + 1 == y || j_y - 1 == y)) do
        eredm ++ [{x, y}]
      else
        satrak_ellenorzes(tents, {x, y}, j + 1, eredm)
      end
    else
      eredm
    end
  end

  @spec fa_vagy_ures(trees :: trees, i :: integer, j :: integer, z :: integer) ::
          resp :: String
  # A trees a fak listaja
  # i az sor koordinata j az oszlop, z pedig egy iterator a listakban
  # egy fat vagy egy ures helyet rak le
  defp fa_vagy_ures(trees, i, j, z) do
    if(z < length(trees)) do
      if Enum.at(trees, z) |> elem(0) == i && Enum.at(trees, z) |> elem(1) == j do
        "*"
      else
        fa_vagy_ures(trees, i, j, z + 1)
      end
    else
      "-"
    end
  end
end
